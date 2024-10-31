abstract class Helix::Species
  def update
  end

  def enable(trait : Class)
    raise "Cannot enable #{trait} because it wasn't in #{self.class}"
  end

  def disable(trait : Class)
    raise "Cannot disable #{trait} because it wasn't in #{self.class}"
  end

  macro finished
    {% for gene in Genes.ancestors %}
    def has_{{gene.id.split("::")[1..].join("_").underscore.id}}? : Bool
      false
    end
    {% end %}

    {% for trait in Traits.ancestors %}
    def can_{{trait.id.split("::")[2..].join("_").underscore.id}}? : Bool
      false
    end
    {% end %}
  end
end