require "wait_group"

module Helix
  module Traits
    macro export_code(trait, type)
      {% 
        parse_type("#{trait}::Genes").resolve.ancestors.select {|g| ::Helix::Genes.ancestors.any? {|g2| g == g2}}.each do |gene| 
          raise "Trait #{trait} cannot be added to #{type} without the #{gene} gene" unless type.resolve < gene 
        end 
      %}

      {% run_method = parse_type("#{trait}::Exec").resolve.methods.find {|m| m.name == "run"} %}
      {% if parse_type("#{trait}::Type").resolve? %}
        {{parse_type("#{trait}::Exec").resolve.constant("ARG_NAME").id}} = self.as({{trait}}::Type)
      {% end %}
      {{run_method.body}}
    end
  end
  
  # Creates a new gene. Genes are the building blocks of Speciess, Genes should hold pure data and associated functions.
  macro gene(name, &block)
    module {{name}}
      {% if block.is_a?(Block) %}
        {{block.body}}
      {% end %}

      def has_{{name.id.split("::").join("_").underscore.id}}? : Bool
        true
      end
    end

    module ::Helix::Genes
      include {{name}}
    end
  end

  # Allows a Species to inherit a gene. 
  macro inherit(name)
    include {{name}}
    \{% raise "Cannot add a gene to something that isn't a Module or a Species" unless @type < Species || @type.module? %}
  end

  # Creates a Trait that can be used to add functionality at the Species level. This takes the name of the trait you'd like to create,
  # as well as a list of Gene types that will be used. The block contains the code to run, and must take the same number of arguments as
  # Genes used. You cannot use the same Gene more than once.
  macro trait(name, *genes, &block)
    {% raise "Gene used more than once in #{genes}" if genes.uniq.size != genes.size %}
    {% raise "Wrong number of arguments in trait block. You must include one argument (the species that has all these genes)" if block.args.size != 1 %}
    {% raise "Trait blocks cannot use splat. Sorry!" if block.splat_index %}
    module {{name}}
      def can_{{name.id.split("::").join("_").underscore.id}}? : Bool
        true
      end
      
      # Tracks the genes needed for this trait
      module Genes
        {% for gene in genes %}
        include {{gene.id}}
        {% end %}
      end

      {% if !genes.empty? && block.args[0] != "_" %}
        alias Type = {{genes.join(" | ").id}}
      {% end %}

      # Hides the trait method implementation
      module Exec
        include Genes

        ARG_NAME = {{block.args[0].stringify}}
        def run()
          {{block.body}}
        end
      end
    end
    
    module ::Helix::Traits
      # Creates a list of all the traits in Traits
      include {{name}}
    end
  end

  macro give(trait_expression)
    {% 
      # First we have to unroll the Call stack so we can start at the top, instead of the bottom.
      root = trait_expression
      linearized = [] of Call
      stack = [nil]
      stack.each do |_| # (While)
        stack << nil # (Seed the next loop)
        if root.is_a?(Call)
          if root.receiver && !root.receiver.is_a?(Path)
            linearized.unshift root
            root = root.receiver
          else
            linearized.unshift root

            stack.clear # (Break) We are at some root
          end
        else
          raise "Found #{root.class_name} - #{root}, expected Call"
          stack.clear
        end
      end
    %}

    # Include all the traits.
    {% for trait_call, index in linearized %}
      {% if index == 0 %}
      include {{trait_call.receiver}}
      {% end %}
      include {{trait_call.args[0]}}
    {% end %}

    macro finished
      # Create a list of all the traits and if they have been enabled or not
      @%traits_enabled : Hash(String, Bool) = {
        {% for trait_call, index in linearized %}
        {% if index == 0 %}
        {{"#{trait_call.receiver}"}} => true,
        {% end %}
        {{"#{trait_call.args[0]}"}} => true,
        {% end %}
      } of String => Bool

      {% 
        # Override the enable and disable method with our actual traits_enabled hash
      %}
      def enable(trait : Class)
        if @%traits_enabled.has_key?(trait.to_s)
          @%traits_enabled[trait.to_s] = true
        else
          raise "Cannot enable #{trait} because it wasn't in #{self.class}"
        end
      end

      def disable(trait : Class)
        if @%traits_enabled.has_key?(trait.to_s)
          @%traits_enabled[trait.to_s] = false
        else
          raise "Cannot disable #{trait} because it wasn't in #{self.class}"
        end
      end

      def update
        {% 
          # Determines if the tokenizer should be changed to collecting a wait group
          waitgroup_mode = false 
          waitgroup_traits = [] of Path
        %}

        {% for trait_call, index in linearized %}
          {% 
            # if the current call is the << (shovel) operator shovel the trait into a waitgroup and turn on wait group mode
          %}
          {% if trait_call.name == "<<" && !waitgroup_mode %}
             {% 
              waitgroup_mode = true
              # Since we are starting the waitgroup we need to get the first part of the shovel
              # Have to treat index 0 special because it's reciever is not an Expressions but a Path
              if index == 0
                waitgroup_traits << trait_call.receiver 
                waitgroup_traits << trait_call.args[0]
              else
                waitgroup_traits << trait_call.receiver.args[0]
                waitgroup_traits << trait_call.args[0]
              end
             %}
          {% 
            # If it is in waitgroup mode and we are still shovelling into a waitgroup, just shovel
          %}
          {% elsif trait_call.name == "<<" && waitgroup_mode %}
            {% waitgroup_traits << trait_call.args[0] %}
          {% 
            # We are in a waitgroup but now we hit the forward shovel so its time to stop and output the waitgroup
          %}
          {% elsif waitgroup_mode && trait_call.name == ">>" %}
            {% waitgroup_mode = false %}
            
            %waitgroup = WaitGroup.new({{waitgroup_traits.size}})

            # Flush the traits into a waitgroup
            {% for trait in waitgroup_traits %}
              spawn do 
                if @%traits_enabled[{{"#{trait}"}}]?
                  ::Helix::Traits.export_code({{trait}}, {{@type}})
                end
              ensure
                %waitgroup.done
              end
            {% end %}

          
            puts "Waiting for #{{{waitgroup_traits.map(&.stringify)}}}"
            %waitgroup.wait
            {% waitgroup_traits.clear %}

            {% if (index + 1 != linearized.size && linearized[index + 1].name != "<<") || (index + 1 == linearized.size) %}
              if @%traits_enabled[{{"#{trait_call.args[0]}"}}]?
                ::Helix::Traits.export_code({{trait_call.args[0]}}, {{@type}})
              end
              {% end %}
          {% elsif trait_call.name == ">>" %}
            {% if index == 0 %}
              if @%traits_enabled[{{"#{trait_call.receiver}"}}]?
                ::Helix::Traits.export_code({{trait_call.receiver}}, {{@type}})
              end
            {% end %}

            {% if index + 1 != linearized.size && linearized[index + 1].name != "<<" %}
              if @%traits_enabled[{{"#{trait_call.args[0]}"}}]?
                ::Helix::Traits.export_code({{trait_call.args[0]}}, {{@type}})
              end
              {% end %}
          {% else %}
            {% raise "invalid token #{trait_call.name}" %}
          {% end %}

        {% end %}
      end
    end
  end
end