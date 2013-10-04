require 'graphviz';

g = Graphviz::Graph.new

foo = g.add_node("Foo")
foo.add_node("Bar")

foo.attributes[:shape] = 'box3d'
foo.attributes[:color] = 'red'

# Dup the dot data:
puts g.to_dot

# Process the graph to output:
Graphviz::output(g, :path => "test.pdf")

