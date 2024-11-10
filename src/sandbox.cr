require "./helix"

include Helix

gene Velocity,
  vx : Float32 = 0.0_f32,
  vy : Float32 = 0.0_f32

trait(Position::Move, Position, Velocity) do |me|
  me.x += me.vx
  me.y += me.vy
  puts "Trait Position::Move ran!"
end

class MySpecies < Species
  inherit Rectangle
  inherit Velocity

  give Position::Move
end

a = MySpecies.new
puts a.x
puts a.y
a.vx = 10.0_f32
a.vy = 10.0_f32
a.update
puts a.x
puts a.y

# puts "Disabled MovePosition"
# a.disable(Position::Move)
# a.update
# puts a.x
# puts a.y
# puts "Enabled MovePosition"
# a.enable(Position::Move)
# a.update
# puts a.x
# puts a.y
# puts a.as(Species).has_position?
# puts a.as(Species).has_velocity?
# puts a.as(Species).can_a?
# puts a.as(Species).can_h?
# puts a.as(Species).can_position_move?
# puts a.as(Species).can_enact_physics?