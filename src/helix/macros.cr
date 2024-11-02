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

  macro give(*traits)
    # Include all the traits.
    {% for trait in traits %}
      {% if trait.is_a?(Path) %}
        include {{trait}}
      {% elsif trait.is_a?(Call) %}
       {% 
          # First we have to unroll the Call stack so we can start at the top, instead of the bottom.
          root = trait
          linearized = [] of Call
          stack = [nil]
          stack.each do |_| # (While)
            stack << nil # (Seed the next loop)
            if root.is_a?(Call)
              raise "Unexpected!" unless root.name == "|"
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
        {% for trait_call, index in linearized %}
          {% if index == 0 %}
            include {{trait_call.receiver}}
          {% end %}
          include {{trait_call.args[0]}}
        {% end %}
      {% else %}
        {% raise "Unexpected!" %}
      {% end %}
    {% end %}

    

    macro finished
      # Create a list of all the traits and if they have been enabled or not
      @%traits_enabled : Hash(String, Bool) = {
        {% for trait in traits %}
          {% if trait.is_a?(Call) %} # Trait is a union
            {% 
              # First we have to unroll the Call stack so we can start at the top, instead of the bottom.
              root = trait
              linearized = [] of Call
              stack = [nil]
              stack.each do |_| # (While)
                stack << nil # (Seed the next loop)
                if root.is_a?(Call)
                  raise "Unexpected!" unless root.name == "|"
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
            {% for trait_call, index in linearized %}
              {% if index == 0 %}
                {{"#{trait_call.receiver}"}} => true,
              {% end %}
              {{"#{trait_call.args[0]}"}} => true,
            {% end %}
          {% else %} # Trait is a path, not a union
            {{"#{trait}"}} => true,
          {% end %}
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
        {% for trait in traits %}

          {% if trait.is_a?(Call) %} # Trait is a union
            {% 
              # First we have to unroll the Call stack so we can start at the top, instead of the bottom.
              root = trait
              linearized = [] of Call
              stack = [nil]
              stack.each do |_| # (While)
                stack << nil # (Seed the next loop)
                if root.is_a?(Call)
                  raise "Unexpected!" unless root.name == "|"
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

            %waitgroup = WaitGroup.new({{linearized.size + 1}})

            {% for trait_call, index in linearized %}
              {% if index == 0 %}
                spawn do 
                  if @%traits_enabled[{{"#{trait_call.receiver}"}}]?
                    ::Helix::Traits.export_code({{trait_call.receiver}}, {{@type}})
                  end
                ensure
                  %waitgroup.done
                end
              {% end %}
              spawn do 
                if @%traits_enabled[{{"#{trait_call.args[0]}"}}]?
                  ::Helix::Traits.export_code({{trait_call.args[0]}}, {{@type}})
                end
              ensure
                %waitgroup.done
              end

            {% end %}

            %waitgroup.wait
          {% else %}
            if @%traits_enabled[{{"#{trait}"}}]?
              ::Helix::Traits.export_code({{trait}}, {{@type}})
            end
          {% end %}
        {% end %}
      end
    end
  end
end