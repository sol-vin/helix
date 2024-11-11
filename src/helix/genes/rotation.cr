Helix.gene Rotation,
  rotation : Float32 = 0.0_f32,
  origin : Raylib::Vector2 = Raylib::Vector2.zero do

  def self.draw(x, y, rotation : Float32, scale = 40, tint : Color = Color::RGBA::WHITE)
    Circle.draw(x, y, 3, tint)
    line = Vector2.unit_y.rotate(rotation).scale(scale) * -1
    line += position
    Raylib.draw_line(x, y, line.x, line.y, tint.to_raylib)
  end
end