require "./helix"

include Helix

gene Velocity,
  vx : Float32 = 0.0_f32,
  vy : Float32 = 0.0_f32

gene Bullet,
  owner : UUID = UUID.new(bytes: StaticArray(UInt8, 16).new(0_u8)),
  damage : Int32 = 10

gene HP,
  hp : Int32 = 100

gene Player

gene Enemy

trait(Position::Move, Position, Velocity) do |me|
  me.x += me.vx
  me.y += me.vy
end

signal(Bullet::Check, Bullet | Rectangle, Player | Rectangle) do |bullet, enemy|
  puts "BULLET CHECK!"
end

species(Player::Object) do 
  include Rectangle
  include Player
end

species(Bullet::Object) do
  include Bullet
  include Rectangle
  include Velocity

  give Position::Move
end

species(Enemy::Object) do
  include Enemy
  include Rectangle
end

Bullet::Check[Bullet::Object.new, Player::Object.new]
Bullet::Check[CoolerBullet::Object.new, Player::Object.new]
