class Helix::SpecializedGroup(T)

  @array : Set(T) =  Set(T).new

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
  
  def <<(item : T)
    raise "Cant add another item to this Group" if (max = max_size?) && max == @array.size
    
    @array << item
  end

  def recycle(&block : Proc(Species)) : Species
    if item = @array.find {|i| i.dead?}
      item.revive
      return item
    end
    raise "Cant add another item to this Group" if (max = max_size?) && max == @array.max_size
    i = yield
    self << i
    return i
  end

  def recycle?(&block)
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