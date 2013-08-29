# -*- mode: ruby coding: utf-8 -*-

IRB.conf[:IRB_NAME] = "rgraphum"

# :DEFAULT => {
#   :PROMPT_I => "%N(%m):%03n:%i> ",
#   :PROMPT_N => "%N(%m):%03n:%i> ",
#   :PROMPT_S => "%N(%m):%03n:%i%l ",
#   :PROMPT_C => "%N(%m):%03n:%i* ",
#   :RETURN => "=> %s\n"
# },
IRB.conf[:PROMPT][:RGRAPHUM] = {
  :PROMPT_I => "%N(%m):%03n:%i> ",
  :PROMPT_N => "%N(%m):%03n:%i> ",
  :PROMPT_S => "%N(%m):%03n:%i%l ",
  :PROMPT_C => "%N(%m):%03n:%i* ",
  :RETURN => "=> %s\n"
}
# IRB.conf[:PROMPT_MODE] = :RGRAPHUM
IRB.conf[:AUTO_INDENT] = true

puts "Welcome to Rgraphum!"
puts
puts "This is an example for Rgraphum"
puts
puts "> graph = Graph.new"
puts ">"
puts "> vertex1 = graph.vertices.build(label: \"Vertex 1\")"
puts "> vertex2 = graph.vertices.build(label: \"Vertex 2\")"
puts "> vertex3 = graph.vertices.build(label: \"Vertex 3\")"
puts "> "
puts "> edge1 = graph.edges.build(source: vertex1, target: vertex2, weight: 1)"
puts "> edge2 = graph.edges.build(source: vertex2, target: vertex3, weight: 1)"
puts "> edge3 = graph.edges.build(source: vertex3, target: vertex1, weight: 1)"
puts "> "
puts "> open('sample.gexf', 'w') do |f|"
puts ">   f.puts graph.to_gephi"
puts "> end"
puts
puts "Enter 'quit' to exit."
puts
