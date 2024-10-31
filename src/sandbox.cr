require "./helix"

include Helix

gene Position do
  property x : Float32 = 0.0_f32
  property y : Float32 = 0.0_f32
end

gene Velocity do
  property vx : Float32 = 0.0_f32
  property vy : Float32 = 0.0_f32
end

trait(MovePosition, Position, Velocity) do
  self.x += self.vx
  self.y += self.vy
  puts "MovePosition trait ran!"
end

trait(EnactPhysics, Position, Velocity) do
  puts "EnactPhysics trait ran!"
end

trait(A) do
  puts "A trait ran!"
end

trait(B) do
  puts "B trait ran!"
end

trait(C) do
  puts "C trait ran!"
end

trait(D) do
  puts "D trait ran!"
end

trait(E) do
  puts "E trait ran!"
end

trait(F) do
  puts "F trait ran!"
end

trait(G) do
  puts "G trait ran!"
end

trait(H) do
  puts "H trait ran!"
end

class MySpecies < Species
  inherit Position
  inherit Velocity

  give(
    MovePosition >>
    A << B << C >>
    D >>
    E >> 
    F << G >> 
    H
  )
end

a = MySpecies.new
puts a.x
puts a.y
a.vx = 10.0_f32
a.vy = 10.0_f32
a.update
puts a.x
puts a.y
disable(a, MovePosition)
a.update
puts a.x
puts a.y
enable(a, MovePosition)
a.update
puts a.x
puts a.y
puts a.as(Species).has_position?
puts a.as(Species).has_velocity?
puts a.as(Species).can_a?
puts a.as(Species).can_h?
puts a.as(Species).can_move_position?

