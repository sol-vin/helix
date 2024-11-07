require "./helix"

include Helix 

gene Position,
  x : Float32 = 0.0_f32,
  y : Float32 = 0.0_f32

gene Velocity,
  vx : Float32 = 0.0_f32,
  vy : Float32 = 0.0_f32


trait(Position::Move, Position, Velocity) do |me|
  me.x += me.vx
  me.y += me.vy
  puts "Position::Move trait ran!"
end

trait(Enact::Physics, Position, Velocity) do |_|
  puts "EnactPhysics trait ran!"
end

trait(A, Position) do |_|
  puts "A trait ran!"
end

trait(B, Position) do |_|
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

  give Position::Move,
    A | B | C,
    D | E,
    F | G,
    H
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
a.disable(Position::Move)
a.update
puts a.x
puts a.y
puts "Enabled MovePosition"
a.enable(Position::Move)
a.update
puts a.x
puts a.y
puts a.as(Species).has_position?
puts a.as(Species).has_velocity?
puts a.as(Species).can_a?
puts a.as(Species).can_h?
puts a.as(Species).can_position_move?
puts a.as(Species).can_enact_physics?