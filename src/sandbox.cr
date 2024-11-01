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

trait(MovePosition, Position, Velocity) do |me|
  me.x += me.vx
  me.y += me.vy
  puts "MovePosition trait ran!"
end

trait(EnactPhysics, Position, Velocity) do |_|
  puts "EnactPhysics trait ran!"
end

trait(A) do |_|
  puts "A trait ran!"
end

trait(B) do |_|
  puts "B trait ran!"
end

trait(C) do |_|
  puts "C trait ran!"
end

trait(D) do |_|
  puts "D trait ran!"
end

trait(E) do |_|
  puts "E trait ran!"
end

trait(F) do |_|
  puts "F trait ran!"
end

trait(G) do |_|
  puts "G trait ran!"
end

trait(H) do |_|
  puts "H trait ran!"
end

trait(I) do |_|
  puts "I trait ran!"
end

class MySpecies < Species
  inherit Position
  inherit Velocity

  give(
    MovePosition >>
    A << B << C <<
    D >>
    E << 
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
puts "Disabled MovePosition"
disable(a, MovePosition)
a.update
puts a.x
puts a.y
puts "Enabled MovePosition"
enable(a, MovePosition)
a.update
puts a.x
puts a.y
puts a.as(Species).has_position?
puts a.as(Species).has_velocity?
puts a.as(Species).can_a?
puts a.as(Species).can_h?
puts a.as(Species).can_move_position?
