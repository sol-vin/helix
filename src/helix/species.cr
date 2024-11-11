abstract class Helix::Species
  getter id : UUID

  getter? destroyed = false

  def initialize
    @id = UUID.random
  end

  def destroy
    unless @destroyed
      @destroyed = true
      #emit Destroyed, self
    end
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