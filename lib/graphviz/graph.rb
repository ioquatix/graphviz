# Copyright, 2014, by Samuel G. D. Williams. <http://www.codeotaku.com>
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
	# Represents a visual node in the graph, which can be connected to other nodes.
	class Node
		# Initialize the node in the graph with the unique name.
		# @param attributes [Hash] The associated graphviz attributes for this node.
		def initialize(graph, name, attributes = {})
			@graph = graph
			@graph.nodes[name] = self
			
			@name = name
			@attributes = attributes
			
			@edges = []
		end
		
		# @return [String] The unique name of the node.
		attr :name
		
		# @return [Array<Edge>] Any edges connecting to other nodes.
		attr :edges
		
		# @return [Hash] Any attributes specified for this node.
		attr_accessor :attributes
		
		# Create an edge between this node and the destination with the specified options.
		# @param attributes [Hash] The associated graphviz attributes for the edge.
		def connect(destination, attributes = {})
			edge = Edge.new(@graph, self, destination, attributes)
			
			@edges << edge
			
			return edge
		end
		
		# Calculate if this node is connected to another. +O(N)+ search required.
		def connected?(node)
			return @edges.find{|edge| edge.destination == node}
		end
		
		# Add a node and #connect to it.
		# @param attributes [Hash] The associated graphviz attributes for the new node.
		def add_node(name, attributes = {})
			node = Node.new(@graph, name, attributes)
			
			connect(node)
			
			return node
		end
	end
	
	# Represents a visual edge between two nodes.
	class Edge
		# Initialize the edge in the given graph, with a source and destination node.
		# @param attributes [Hash] The associated graphviz attributes for this edge.
		def initialize(graph, source, destination, attributes = {})
			@graph = graph
			@graph.edges << self
			
			@source = source
			@destination = destination
			
			@attributes = attributes
		end
		
		# @return [Node] The source node.
		attr :source
		
		# @return [Node] The destination node.
		attr :destination
		
		# @return [Hash] Any attributes specified for this edge.
		attr_accessor :attributes
		
		# @return [String] A convenient ASCII arrow.
		def to_s
			'->'
		end
	end
	
	# Contains a set of nodes, edges and subgraphs.
	class Graph
		# Initialize the graph with the specified unique name.
		def initialize(name = 'G', attributes = {})
			@name = name
			
			@nodes = {}
			@edges = []
			@graphs = {}
			
			@parent = nil
			
			@attributes = attributes
		end
		
		# @return [Graph] The parent graph, if any.
		attr :parent
		
		# @return [Array<Node>] All nodes in the graph.
		attr :nodes
		
		# @return [Array<Edge>] All edges in the graph.
		attr :edges
		
		# @return [Array<Graph>] Any subgraphs.
		attr :graphs
		
		# @return [Hash] Any associated graphviz attributes.
		attr_accessor :attributes
		
		# @return [Node] Add a node to this graph.
		def add_node(name, attributes = {})
			Node.new(self, name, attributes)
		end
		
		# Add a subgraph with a given name and attributes.
		# @return [Graph] the new graph.
		def add_subgraph(name, attributes = {})
			graph = Graph.new(name, attributes)
			
			graph.attach(self)
			@graphs[name] = graph
			
			return graph
		end
		
		# Make this graph a subgraph of the parent.
		def attach(parent)
			@parent = parent
		end
		
		# @return [String] Output the graph using the dot format.
		def to_dot(options = {})
			buffer = StringIO.new
			
			dump_graph(buffer, "", options)
			
			return buffer.string
		end
		
		protected
		
		# Dump the entire graph and all subgraphs to dot text format.
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
		
		# Dump the value to dot text format.
		def dump_value(value)
			if Symbol === value
				value.to_s
			else
				value.inspect
			end
		end
		
		# Dump the attributes to dot text format.
		def dump_attributes(attributes)
			if attributes.size > 0
				"[" + attributes.collect{|(name, value)| "#{name}=#{dump_value(value)}"}.join(", ") + "]"
			else
				""
			end
		end
	end
end
