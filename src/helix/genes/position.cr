Helix.gene Helix::Position,
  x : Float32 = 0.0_f32,
  y : Float32 = 0.0_f32

module Helix::Position
  def follow(x, y, speed = 1.0_f32)
    @x += (x - @x) * speed
    @y += (y - @y) * speed
  end

  def follow(pos : Position, offset : Position = Vector2.zero, speed = 1.0_f32)
    follow(pos.x, pos.y, speed)
  end

  def follow(pos : Vector2, offset : Position = Vector2.zero, speed = 1.0_f32)
    follow(pos.x, pos.y, speed)
  end
end

struct ::Raylib::Vector2
  # Modify vector2 to include Position for easier typing
  include Helix::Position
end