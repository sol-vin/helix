abstract class Helix::Species
  abstract def update

  abstract def enable(trait : Class)

  abstract def disable(trait : Class)

  macro finished
    {% for gene in Genes.ancestors %}
    def has_{{gene.id.split("::").join("_").underscore.id}}? : Bool
      false
    end
    {% end %}

    {% for trait in Traits.ancestors %}
    def can_{{trait.id.split("::").join("_").underscore.id}}? : Bool
      false
    end
    {% end %}
  end
end