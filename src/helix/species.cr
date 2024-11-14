abstract class Helix::Species
  getter id : UUID

  getter? alive = true

  def initialize
    @id = UUID.random
  end

  def dead?
    !@alive
  end

  def kill
    @alive = false
  end

  def revive
    @alive = true
  end

  def_equals_and_hash @id, @id.hash

  def update
  end

  def enable(trait : Class)
  end

  def disable(trait : Class)
  end

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