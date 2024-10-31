macro test(lineage)
  # Unpack potential expressions (for if someone wraps a call like `macro(((A|B|C)))` )
  {% 
    root = lineage
    linearized = [] of Call
    stack = [nil]
    stack.each do |_| # (While)
      stack << nil # (Seed the next loop)
      if root.is_a?(Call)
        if root.receiver && !root.receiver.is_a?(Path)
          linearized.unshift root
          root = root.receiver
          puts "into #{root}"
        else
          linearized.unshift root

          stack.clear # (Next) We are at some root
          puts "Found top call #{root}"
          puts "Found top call args #{root.args}"
        end
      else
        raise "Found #{root.class_name} - #{root}, expected Call"
        stack.clear
      end
    end

    puts linearized.map_with_index {|c, i| "#{c.receiver if i == 0}#{c.name}#{c.args[0]}"}
  %}
end

test(
  A >>
    B >>
      C >>
        D | E | F
)

