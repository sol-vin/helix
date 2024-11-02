macro signal(name, a, b, &block)
  {% 
    puts a, b 
    puts block.body 
  %}
end

signal DamageCheck, Bullet | Rectangle, Enemy | Rectangle | Health do |bullet, enemy|
  if bullet.intersects?(enemy)
    enemy.damage(bullet.damage)
  end
end
