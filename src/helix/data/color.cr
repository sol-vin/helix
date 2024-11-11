abstract struct Helix::Color
  RED     = Helix::Color::RGBA.new(r: 255, a: 255)
  YELLOW  = Helix::Color::RGBA.new(r: 255, g: 255, a: 255)
  GREEN   = Helix::Color::RGBA.new(g: 255, a: 255)
  CYAN    = Helix::Color::RGBA.new(g: 255, b: 255, a: 255)
  BLUE    = Helix::Color::RGBA.new(b: 255, a: 255)
  MAGENTA = Helix::Color::RGBA.new(r: 255, b: 255, a: 255)
  WHITE   = Helix::Color::RGBA.new(r: 255, g: 255, b: 255, a: 255)
  BLACK   = Helix::Color::RGBA.new(r: 0, g: 0, b: 0, a: 255)
  CLEAR   = Helix::Color::RGBA.new(r: 0, g: 0, b: 0, a: 0)

  abstract def to_rgba : RGBA

  def to_raylib : Raylib::Color
    c = self.to_rgba
    Raylib::Color.new(r: c.r, g: c.g, b: c.b, a: c.a)
  end
end

struct Helix::Color::RGBA < Helix::Color
  property r : UInt8 = 0_u8
  property g : UInt8 = 0_u8
  property b : UInt8 = 0_u8
  property a : UInt8 = 0_u8

  def initialize(r : Number = 0_u8, g : Number = 0_u8, b : Number = 0_u8, a : Number = 0_u8)
    @r = r.to_u8
    @g = g.to_u8
    @b = b.to_u8
    @a = a.to_u8
  end

  def to_rgba : RGBA
    self
  end

  def fade(alpha : Float) : RGBA
    alpha = alpha.clamp(0.0, 1.0)

    RGBA.new(@r, @g, @b, alpha * @a)
  end
end

# TODO: Finish colors
# struct Helix::Color::HSVA < Helix::Color
#   property h : Float32 = 0.0_f32
#   property s : Float32 = 0.0_f32
#   property v : Float32 = 0.0_f32
#   property a : Float32 = 0.0_f32

#   def initialize(h : Number = 0.0_f32, s : Number = 0.0_f32, v : Number = 0.0_f32, a : Number = 0.0_f32)
#     @h = h.to_f32
#     @s = s.to_f32
#     @v = v.to_f32
#     @a = a.to_f32
#   end

#   def to_rgba : RGBA
#     #TODO: This part
#   end
# end

# struct Helix::Color::HSLA < Helix::Color
#   property h : Float32 = 0.0_f32
#   property s : Float32 = 0.0_f32
#   property l : Float32 = 0.0_f32
#   property a : Float32 = 0.0_f32

#   def initialize(h : Number = 0.0_f32, s : Number = 0.0_f32, l : Number = 0.0_f32, a : Number = 0.0_f32)
#     @h = h.to_f32
#     @s = s.to_f32
#     @l = l.to_f32
#     @a = a.to_f32
#   end

#   def to_rgba : RGBA
#     #TODO: This part
#   end
# end

# struct Helix::Color::HSIA < Helix::Color
#   property h : Float32 = 0.0_f32
#   property s : Float32 = 0.0_f32
#   property i : Float32 = 0.0_f32
#   property a : Float32 = 0.0_f32

#   def initialize(h : Number = 0.0_f32, s : Number = 0.0_f32, i : Number = 0.0_f32, a : Number = 0.0_f32)
#     @h = h.to_f32
#     @s = s.to_f32
#     @i = i.to_f32
#     @a = a.to_f32
#   end

#   def to_rgba : RGBA
#     #TODO: This part
#   end
# end

# struct Helix::Color::XYZA < Helix::Color
#   property x : Float32 = 0.0_f32
#   property y : Float32 = 0.0_f32
#   property z : Float32 = 0.0_f32
#   property a : Float32 = 0.0_f32

#   def initialize(x : Number = 0.0_f32, y : Number = 0.0_f32, z : Number = 0.0_f32, a : Number = 0.0_f32)
#     @x = x.to_f32
#     @y = y.to_f32
#     @z = z.to_f32
#     @a = a.to_f32
#   end

#   def to_rgba : RGBA
#     #TODO: This part
#   end
# end

# struct Helix::Color::LABA < Helix::Color
#   property l : Float32 = 0.0_f32
#   property a : Float32 = 0.0_f32
#   property b : Float32 = 0.0_f32
#   property alpha : Float32 = 0.0_f32

#   def initialize(l : Number = 0.0_f32, a : Number = 0.0_f32, b : Number = 0.0_f32, alpha : Number = 0.0_f32)
#     @l = l.to_f32
#     @a = a.to_f32
#     @b = b.to_f32
#     @alpha = alpha.to_f32
#   end

#   def to_rgba : RGBA
#     #TODO: This part
#   end
# end

# struct Helix::Color::LCHA < Helix::Color
#   property l : Float32 = 0.0_f32
#   property c : Float32 = 0.0_f32
#   property h : Float32 = 0.0_f32
#   property a : Float32 = 0.0_f32

#   def initialize(l : Number = 0.0_f32, c : Number = 0.0_f32, h : Number = 0.0_f32, a : Number = 0.0_f32)
#     @l = l.to_f32
#     @c = c.to_f32
#     @h = h.to_f32
#     @a = a.to_f32
#   end

#   def to_rgba : RGBA
#     #TODO: This part
#   end
# end