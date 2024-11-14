require "./helix"

include Helix

gene Velocity,
  vx : Float32 = 0.0_f32,
  vy : Float32 = 0.0_f32

gene Bullet,
  owner : UUID = UUID.new(bytes: StaticArray(UInt8, 16).new(0_u8)),
  damage : Int32 = 10

gene Enemy,
  hp : Int32 = 100

gene Player,
  hp : Int32 = 100

trait(Position::Move, Position, Velocity) do |me|
  me.x += me.vx
  me.y += me.vy
  puts "Trait Position::Move ran!"
end

signal(Bullet::Check, Bullet | Rectangle, Player | Rectangle) do |bullet, enemy|
  if Rectangle.intersects?(bullet, enemy)
    enemy.hp -= bullet.damage
  end
end

species(PlayerObject) do 
  include Rectangle
  include Velocity
  include Player

  give Position::Move
end

species(MyBullet) do
  include Bullet
  include Rectangle
  include Velocity
end

a = .new
puts a.id.to_human
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
puts a.as(Species).can_position_move?

g2 = Helix::Group.new(max_size: 3)
g2 << a

g2.recycle? { puts "New item made (MySpecies - #{g2.size})";MySpecies.new }
g2.each(&.kill)
puts "Recycling"
g2.recycle? { puts "New item made (MySpecies - #{g2.size})";MySpecies.new }
puts "Done Recycling"

g2.recycle? { puts "New item made (MySpecies - #{g2.size})";MySpecies.new }
g2.recycle? { puts "New item made (MySpecies - #{g2.size})";MySpecies.new }
g2.recycle? { puts "New item made (MySpecies - #{g2.size})";MySpecies.new }
g2.recycle? { puts "New item made (MySpecies - #{g2.size})";MySpecies.new }
g2.recycle? { puts "New item made (MySpecies - #{g2.size})";MySpecies.new }


# g3 = Helix::SpecializedGroup(Int32).new
