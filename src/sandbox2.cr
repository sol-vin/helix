macro amalgam(name, *types)
  module {{name}}
    {% for type in types %}
    include {{type}}
    {% end %}
  end

  module Amalgams
    include {{name}}
  end
end

module AllowAmalgam
  macro finished
    {% for includer in @type.includers %}
      {% for amalgam in Amalgams.ancestors %}
        # We have all the types requires for the amalgam in includer?
        {% if (amalgam.ancestors - includer.ancestors).empty? %}
          # Assume its a class for simplicity but we should check for struct, enum, etc.
          class ::{{includer}}
            include {{amalgam}}
          end
        {% end %}
      {% end %}
    {% end %}
  end
end

# Main

module A
  property a : Char = 'a'
end

module B
  property b : Char = 'b'
end

module C
  property c : Char = 'c'
end

amalgam(ABC, A, B, C)

class Item1
  include AllowAmalgam
  include A
  include B
  include C
end

class Item2
  include AllowAmalgam
  include A
  include B
  include C
end

class Item3
  include A
  include B
  include C
end

def only_amalgams(abc : ABC)
  puts "#{abc.a}#{abc.b}#{abc.c}"
end

only_amalgams(Item1.new)
only_amalgams(Item2.new)
# only_amalgams(Item3.new) # => Error



