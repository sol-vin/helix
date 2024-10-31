require "wait_group"

module Helix
  module Traits
  end
  
  # Creates a new gene. Genes are the building blocks of Speciess, Genes should hold pure data and associated functions.
  macro gene(name, &block)
    module ::Helix::Genes
      module {{name}}

        {% if block.is_a?(Block) %}
          {{block.body}}
        {% end %}

        def has_{{name.id.split("::").join("_").underscore.id}}? : Bool
          true
        end
      end

      include {{name}}
    end
  end

  # Allows a Species to inherit a gene. 
  macro inherit(name)
    include ::Helix::Genes::{{name}}
    \{% raise "Cannot add a gene to something that isn't a Module or a Species" unless @type < Species || @type.module? %}
  end

  # Creates a Trait that can be used to add functionality at the Species level. This takes the name of the trait you'd like to create,
  # as well as a list of Gene types that will be used. The block contains the code to run, and must take the same number of arguments as
  # Genes used. You cannot use the same Gene more than once.
  macro trait(name, *genes, &block)
    {% raise "Gene used more than once in #{genes}" if genes.uniq.size != genes.size %}
    {% raise "Wrong number of arguments in trait block. You must include no arguments (self is the object that uses the trait)" if block.args.size != 0 %}
    {% raise "Trait blocks cannot use splat. Sorry!" if block.splat_index %}
    module ::Helix::Traits
      module {{name}}
        def can_{{name.id.split("::").join("_").underscore.id}}? : Bool
          true
        end
        
        # Tracks the genes needed for this trait
        module Genes
          {% for gene in genes.map {|g| "::Helix::Genes::#{g}"} %}
          include {{gene.id}}
          {% end %}
        end

        # Hides the trait method implementation
        module Exec
          include ::Helix::Traits::{{name}}::Genes

          def run
            {{block.body}}
          end
        end
      end

      # Creates a list of all the traits in Traits
      include {{name}}
    end
  end

  macro give(trait_expression)
    {% 
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

            stack.clear # (Next) We are at some root
          end
        else
          raise "Found #{root.class_name} - #{root}, expected Call"
          stack.clear
        end
      end
    %}

    {% for trait_call, index in linearized %}
      {% if index == 0 %}
      include ::Helix::Traits::{{trait_call.receiver}}
      {% end %}
      include ::Helix::Traits::{{trait_call.args[0]}}
    {% end %}

    macro finished
      @%traits_enabled : Hash(String, Bool) = {
        {% for trait_call, index in linearized %}
        {% if index == 0 %}
        {{"Helix::Traits::#{trait_call.receiver}"}} => true,
        {% end %}
        {{"Helix::Traits::#{trait_call.args[0]}"}} => true,
        {% end %}
      } of String => Bool

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
        {% waitgroup_mode = false %}
        {% waitgroup_traits = [] of Path %}

        {% for trait_call, index in linearized %}
          {% if trait_call.name == "<<" && !waitgroup_mode %}
             {% 
              waitgroup_mode = true 
              if index == 0
                waitgroup_traits << trait_call.receiver 
                waitgroup_traits << trait_call.args[0]
              else
                waitgroup_traits << trait_call.receiver.args[0]
                waitgroup_traits << trait_call.args[0]
              end
             %}
          {% elsif trait_call.name == "<<" && waitgroup_mode %}
            {% waitgroup_traits << trait_call.args[0] %}
          {% elsif waitgroup_mode && trait_call.name == ">>" %}
            {% waitgroup_mode = false %}
            
            %waitgroup = WaitGroup.new({{waitgroup_traits.size}})

            # Flush the traits into a waitgroup
            {% for trait in waitgroup_traits %}
              spawn do 
                if @%traits_enabled[{{"Helix::Traits::#{trait}"}}]?
                  {{parse_type("::Helix::Traits::#{trait}::Exec").resolve.methods.find {|m| m.name == "run"}.body}}
                end
              ensure
                %waitgroup.done
              end
            {% end %}

          
            puts "Waiting for #{{{waitgroup_traits.map(&.stringify)}}}"
            %waitgroup.wait
            {% waitgroup_traits.clear %}

       

            {% for gene in parse_type("::Helix::Traits::#{trait_call.args[0]}::Genes").resolve.ancestors.select {|g| ::Helix::Genes.ancestors.any? {|g2| g == g2}} %}
              {% raise "Trait #{trait_call.args[0]} cannot be added to #{@type} without the #{gene} gene" unless @type < gene %}
            {% end %}

            if @%traits_enabled[{{"Helix::Traits::#{trait_call.args[0]}"}}]?
              {{parse_type("::Helix::Traits::#{trait_call.args[0]}::Exec").resolve.methods.find {|m| m.name == "run"}.body}}
            end
          {% elsif trait_call.name == ">>" %}
            {% if index == 0 %}
              {% for gene in parse_type("::Helix::Traits::#{trait_call.receiver}::Genes").resolve.ancestors.select {|g| ::Helix::Genes.ancestors.any? {|g2| g == g2}} %}
                {% raise "Trait #{trait_call.receiver} cannot be added to #{@type} without the #{gene} gene" unless @type < gene %}
              {% end %}


              if @%traits_enabled[{{"Helix::Traits::#{trait_call.receiver}"}}]?
                {{parse_type("::Helix::Traits::#{trait_call.receiver}::Exec").resolve.methods.find {|m| m.name == "run"}.body}}
              end
            {% end %}

            {% if index + 1 != linearized.size && linearized[index + 1].name != "<<" %}
              {% for gene in parse_type("::Helix::Traits::#{trait_call.args[0]}::Genes").resolve.ancestors.select {|g| ::Helix::Genes.ancestors.any? {|g2| g == g2}} %}
                {% raise "Trait #{trait_call.args[0]} cannot be added to #{@type} without the #{gene} gene" unless @type < gene %}
              {% end %}

              if @%traits_enabled[{{"Helix::Traits::#{trait_call.args[0]}"}}]?
                {{parse_type("::Helix::Traits::#{trait_call.args[0]}::Exec").resolve.methods.find {|m| m.name == "run"}.body}}
              end
              {% end %}
          {% else %}
            {% raise "invalid token #{trait_call.name}" %}
          {% end %}

        {% end %}
      end
    end
  end

  macro enable(object, trait)
    {{object}}.enable(::Helix::Traits::{{trait}})
  end

  macro disable(object, trait)
    {{object}}.disable(::Helix::Traits::{{trait}})
  end
end