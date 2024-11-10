Helix.gene Helix::Circle::Bounds,
  radius : Float32 = 0.0_f32


Helix.gene Helix::Circle

module Helix::Circle
  include Helix::Position
  include Helix::Circle::Bounds

  def self.draw(x, y, radius, tint : Color = Color::RGBA::WHITE, fill = false)
    if fill
      Raylib.draw_circle(x, y, radius, tint.to_rgba.to_raylib)
    else
      Raylib.draw_circle_lines(x, y, radius, tint.to_rgba.to_raylib)
    end
  end

  def self.draw(c : Circle, tint : Color = Color::RGBA::WHITE, fill = false)
    draw(c.x, c.y, c.radius, tint, fill)
  end
end