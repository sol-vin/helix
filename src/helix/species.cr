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