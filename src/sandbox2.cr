module A
  def a
    puts "A"
  end
end

module B
  def b
    puts "B"
  end
end

alias AB = A | B

class C
  include A
  include B
end

def test(ab : AB)
  ab.a
  ab.b
end

C.new.as(AB).a