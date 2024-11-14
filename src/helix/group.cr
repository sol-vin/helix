class Helix::SpecializedGroup(T)

  @array : Set(T) = Set(T).new

  getter? max_size : Int32? = nil

  include Enumerable(T)

  def initialize(@max_size = nil)
    {% raise "T must be of type Helix::Species" unless T < Helix::Species || T == Helix::Species %}
  end

  def size
    @array.size
  end

  def each(&)
    @array.each { |i| yield i }
  end

  def add(item : T)
    self << item
  end

  def add(&block : Proc(T))
    if (max = max_size?) && max == @array.size
      raise "Cant add another item to this Group" unless replace_first_dead? &block
    else
      @array << yield
    end
  end

  def add?(&block : Proc(T))
    if (max = max_size?) && max == @array.size
      replace_first_dead? &block
    else
      @array << yield
    end
  end
  
  def <<(item : T)
    if (max = max_size?) && max == @array.size
      raise "Cant add another item to this Group" unless replace_first_dead?(item)
    else
      @array << item
    end
  end

  private def replace_first_dead?(item : T) : Bool
    @array.each_with_index do |o, i|
      if o.dead?
        @array.delete(o)
        @array << item
        return true
      end
    end

    return false
  end

  private def replace_first_dead?(&block : Proc(T)) : Bool
    @array.each_with_index do |o, i|
      if o.dead?
        @array.delete(o)
        @array << yield
        return true
      end
    end

    return false
  end

  def recycle(&block : Proc(T)) : T
    if item = @array.find {|i| i.dead?}
      item.revive
      return item
    end
    if (max = max_size?) && max == @array.max_size
      raise "Cant add another item to this Group" 
    else
      i = _replace_first_dead &block
      return i
    end
  end

  def recycle?(&block : Proc(T)) : T?
    if item = @array.find {|i| i.dead?}
      item.revive
      return item
    end

    if (max = max_size?) && max == @array.size
      return nil 
    end
    i = yield
    self << i
    return i
  end
end

class Helix::Group < Helix::SpecializedGroup(Helix::Species)
end