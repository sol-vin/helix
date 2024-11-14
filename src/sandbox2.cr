# signal(Bullet::Check, Bullet | Rectangle, Enemy | Rectangle) do |bullet, enemy|
#   if Rectangle.intersects?(bullet, enemy)
#     enemy.hp -= bullet.damage
#   end
# end
# 

# module Bullet::Check
#   module Type1
#     include Bullet
#     include Rectangle
#   end

#   module Type2
#     include Enemy
#     include Rectangle
#   end

#   def self.[](bullet : Type1, enemy : Type2)
#     if Rectangle.intersects?(bullet, enemy)
#       enemy.hp -= bullet.damage
#     end
#   end
# end

# module ::Helix::Signals
#   include Bullet::Check
# end

# Bullet::Check[item1, item2]

{% puts parse_type("Int32 | Float32").types %}



