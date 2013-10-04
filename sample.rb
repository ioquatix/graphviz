require 'graphviz';

g = Graphviz::Graph.new

foo = g.add_node("Foo")
foo.add_node("Bar")

puts g.to_dot

Graphviz::output(g, :path => "test.pdf")
