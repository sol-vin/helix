module A
  @myvar = 100 # Error: instance variable '@myvar' of C must be Int32, not (Float64 | Int32)
end 

module B
  @myvar = 100.0
end 

class C
  include A
  include B
  @myvar = "One hundred"
end

puts C.new.@myvar