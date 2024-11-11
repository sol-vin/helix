Helix.gene IOBB do
  include Rectangle
  include Rotation

  alias Points = StaticArray(Vector2, 4)

  def self.get_points(x, y, width, height, rotation = 0.0_f32, origin : Vector2 = Vector2.zero) : Points
    points = Points.new(Vector2.zero)
    sin_rotation = Math.sin(rotation)
    cos_rotation = Math.cos(rotation)

    dx = -origin.x
    dy = -origin.y

    top_left = Vector2.zero
    top_right = Vector2.zero
    bottom_right = Vector2.zero
    bottom_left = Vector2.zero

    top_left.x = x + dx*cos_rotation - dy*sin_rotation
    top_left.y = y + dx*sin_rotation + dy*cos_rotation

    top_right.x = x + (dx + width)*cos_rotation - dy*sin_rotation
    top_right.y = y + (dx + width)*sin_rotation + dy*cos_rotation

    bottom_left.x = x + dx*cos_rotation - (dy + height)*sin_rotation
    bottom_left.y = y + dx*sin_rotation + (dy + height)*cos_rotation

    bottom_right.x = x + (dx + width)*cos_rotation - (dy + height)*sin_rotation
    bottom_right.y = y + (dx + width)*sin_rotation + (dy + height)*cos_rotation

    points[0] = top_left
    points[1] = top_right
    points[2] = bottom_right
    points[3] = bottom_left
    points
  end

  def self.get_points(r : Rectangle, rotation = 0.0_f32, origin : Vector2 = Vector2.zero) : Points
    IOBB.get_points(r.x, r.y, r.width, r.height, rotation, origin)
  end

  def self.draw(points : Points, color : Color = Color::RGBA::WHITE)
    color = tint.to_raylib
    Raylib.draw_line(points[0].x, points[0].y, points[1].x, points[1].y, color)
    Raylib.draw_line(points[1].x, points[1].y, points[2].x, points[2].y, color)
    Raylib.draw_line(points[2].x, points[2].y, points[3].x, points[3].y, color)
    Raylib.draw_line(points[3].x, points[3].y, points[0].x, points[0].y, color)
  end

  def self.draw_points(points : Points, color : Color = Color::RGBA::WHITE, display_text_size : Int32? = nil, text_color : Color = Color::RGBA::WHITE)
    points.each do |point|
      Raylib.draw_circle_v(point, 4, color.to_raylib)
      if dts = display_text_size
        Raylib.draw_text("#{point.x.round(1)}, #{point.y.round(1)}", point.x, point.y, dts, text_color.to_raylib) 
      end
    end
  end

  def points : Points
    IOBB.get_points(x, y, width, height, rotation, origin)
  end
end