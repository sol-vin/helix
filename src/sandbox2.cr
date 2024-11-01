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

alias C = A | B

class D
  include A
  include B
end

d = D.new
d.a
d.b

c = D.new.as(C)
c.a
c.b
