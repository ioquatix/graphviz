# Copyright (c) 2013 Samuel G. D. Williams. <http://www.codeotaku.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

require 'stringio'

module Graphviz
	class Node
		def initialize(graph, name, attributes = {})
			@graph = graph
			@graph.nodes[name] = self
			
			@name = name
			@attributes = attributes
			
			@edges = []
		end
		
		attr :name
		attr :options
		
		attr :edges
		attr_accessor :attributes
		
		def connect(destination, options = {})
			edge = Edge.new(@graph, self, destination, options)
			
			@edges << edge
			
			return edge
		end
		
		def connected?(node)
			return @edges.find{|edge| edge.destination == node}
		end
		
		def add_node(name, options = {})
			node = Node.new(@graph, name, options)
			
			connect(node)
			
			return node
		end
	end
	
	class Edge
		def initialize(graph, source, destination, attributes = {})
			@graph = graph
			@graph.edges << self
			
			@source = source
			@destination = destination
			
			@attributes = attributes
		end
		
		attr :source
		attr :destination
		
		attr_accessor :attributes
		
		attr :options
		attr_accessor :line
		
		def to_s
			'->'
		end
	end
	
	class EdgeNode < Node
	end
	
	class Graph
		def initialize(name = 'G', attributes = {})
			@name = name
			
			@nodes = {}
			@edges = []
			@graphs = {}
			
			@parent = nil
			
			@attributes = attributes
		end
		
		attr :nodes
		attr :edges
		attr :graphs
		
		attr_accessor :attributes
		
		def add_node(name, attributes = {})
			Node.new(self, name, attributes)
		end
		
		def add_subgraph(name, attributes = {})
			graph = Graph.new(name, attributes)
			
			graph.attach(self)
			@graphs[name] = graph
			
			return graph
		end
		
		def attach(parent)
			@parent = parent
		end
		
		def to_dot(options = {})
			buffer = StringIO.new
			
			dump_graph(buffer, "", options)
			
			return buffer.string
		end
		
		protected
		
		def dump_graph(buffer, indent, options)
			format = options[:format] || 'digraph'
			
			buffer.puts "#{indent}#{format} #{dump_value(@name)} {"
			
			@attributes.each do |(name, value)|
				buffer.puts "#{indent}\t#{name}=#{dump_value(value)};"
			end
			
			@nodes.each do |(name, node)|
				node_attributes_text = dump_attributes(node.attributes)
				node_name = dump_value(node.name)
				buffer.puts "#{indent}\t#{node_name}#{node_attributes_text};"
				
				if node.edges.size > 0
					node.edges.each do |edge|
						from_name = dump_value(edge.source.name)
						to_name = dump_value(edge.destination.name)
						edge_attributes_text = dump_attributes(edge.attributes)
						
						buffer.puts "#{indent}\t#{from_name} #{edge} #{to_name}#{edge_attributes_text};"
					end
				end
			end
			
			@graphs.each do |(name, graph)|
				graph.dump_graph(buffer, indent + "\t", options.merge(:format => 'subgraph'))
			end
			
			buffer.puts "#{indent}}"
		end
		
		def dump_value(value)
			if Symbol === value
				value.to_s
			else
				value.inspect
			end
		end
		
		def dump_attributes(attributes)
			if attributes.size > 0
				"[" + attributes.collect{|(name, value)| "#{name}=#{dump_value(value)}"}.join(", ") + "]"
			else
				""
			end
		end
	end
end
