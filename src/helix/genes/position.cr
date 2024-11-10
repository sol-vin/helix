Helix.gene Helix::Position,
  x : Float32 = 0.0_f32,
  y : Float32 = 0.0_f32
  
struct ::Raylib::Vector2
  # Modify vector2 to include Position for easier typing
  include Helix::Position
end