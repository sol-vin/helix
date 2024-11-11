Helix.gene Rectangle::Bounds,
  width : Float32 = 0.0_f32,
  height : Float32 = 0.0_f32

Helix.gene Rectangle

module Rectangle
  include Position
  include Bounds

  alias Points = StaticArray(Raylib::Vector2, 4)

  def self.invalid?(width, height)
    width <= 0 || height <= 0
  end

  def self.invalid?(r : Rectangle)
    invalid?(r.width, r.height)
  end

  def self.intersects?(x1, y1, w1, h1, x2, y2, w2, h2)
    intersects?(Raylib::Vector2.new(x1, y1), Raylib::Vector2.new(x1 + w1, y1 + h1), Raylib::Vector2.new(x2, y2), Raylib::Vector2.new(x2 + w2, y2 + h2))
  end

  def self.intersects?(a_min, a_max, b_min, b_max)
    a_min.x < b_max.x &&
      a_max.x > b_min.x &&
      a_min.y < b_max.y &&
      a_max.y > b_min.y
  end

  def self.intersects?(r1 : Rectangle, r2 : Rectangle)
    Rectangle.intersects?(r1.x, r1.y, r1.width, r1.height, r2.x, r2.y, r2.width, r2.height)
  end

  def self.contains?(x1, y1, w1, h1, x2, y2, w2, h2)
    contains?(Raylib::Vector2.new(x1, y1), Raylib::Vector2.new(x1 + w1, y1 + h1), Raylib::Vector2.new(x2, y2), Raylib::Vector2.new(x2 + w2, y2 + h2))
  end

  def self.contains?(a_min, a_max, b_min, b_max)
    a_min.x < b_min.x && a_min.y < b_min.y && a_max.x > b_max.x && a_max.y > b_max.y
  end

  def self.contains?(x1, y1, w1, h1, x2, y2)
    x1 < x2 && y1 < y2 && x1 + w1 > x2 && y1 + w1 > y2
  end

  def self.contains?(r1 : Rectangle, p1 : Rectangle)
    Rectangle.contains?(r1.x, r1.y, r1.width, r1.height, p1.x, p1.y)
  end

  def self.contains?(r : Rectangle, p : Position)
    Rectangle.contains?(r1.x, r1.y, r1.width, r1.height, r2.x, r2.y, r2.width, r2.height)
  end

  def self.draw(x, y, width, height, tint : Color = Color::RGBA::WHITE, fill = false)
    if fill
      Raylib.draw_rectangle(x, y, width, height, tint.to_rgba.to_raylib)
    else
      Raylib.draw_rectangle_lines(x, y, width, height, tint.to_rgba.to_raylib)
    end
  end

  def self.draw(r : Rectangle, tint : Color = Color::RGBA::WHITE, fill = false)
    draw(r.x, r.y, r.width, r.height, tint, fill)
  end

  def left
    x
  end

  def left=(x : Number)
    @x = x.to_f32
  end

  def right
    x + width
  end

  def right=(x : Number)
    @x = (x - width).to_f32
  end

  def bottom
    y + height
  end

  def bottom=(y : Number)
    @y = (y - height).to_f32
  end

  def top
    y
  end

  def top=(y : Number)
    @y = y.to_f32
  end

  def center
    Raylib::Vector2.new(x + width/2, y + height/2)
  end

  def points : Points
    Points[
      Raylib::Vector2.new(left, top),
      Raylib::Vector2.new(right, top),
      Raylib::Vector2.new(right, bottom),
      Raylib::Vector2.new(left, bottom),
    ]
  end
end