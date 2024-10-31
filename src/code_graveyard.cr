macro test(name, other = nil)
  {% puts "test: #{name}" %}

  {{other}}
end

macro after(name, other = nil)
  {% puts "after: #{name}" %}
  {{other}}
end

test Test1, 
  after Test2, 
  after Test3