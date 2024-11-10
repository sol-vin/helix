module A
end

module B
end 

module C
  include A
  include B
end

class D
  include A
  include B
  include C
end

macro finished
  {% puts D.ancestors %}
end