gene Position,
  x : Float32 = 0.0_f32,
  y : Float32 = 0.0_f32 do
  
  # def position : Raylib::Vector2
  #   Raylib::Vector2.new(x: x, y: y)
  # end

  
  # def position=(other : self)
  #   @x = other.x
  #   @y = other.y
  # end

  # def follow(x, y, speed = 1.0_f32)
  #   @x += (x - @x) * speed
  #   @y += (y - @y) * speed
  # end

  # def follow(pos : Position, offset : Position = Vector2.zero, speed = 1.0_f32)
  #   follow(pos.x, pos.y, speed)
  # end

  # def follow(pos : Vector2, offset : Position = Vector2.zero, speed = 1.0_f32)
  #   follow(pos.x, pos.y, speed)
  # end
end

struct ::Raylib::Vector2
  include Position
end