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
		def initialize(name, graph = nil, **attributes)
			@name = name
			@attributes = attributes
			
			@connections = []
			
			graph << self if graph
		end
		
		# Attach this node to the given graph:
		def attach(parent)
			@graph = parent
		end
		
		# @return [String] The unique name of the node.
		attr :name
		
		# @return [Array<Edge>] Any edges connecting to other nodes.
		attr :connections
		
		# @return [Hash] Any attributes specified for this node.
		attr_accessor :attributes
		
		# Create an edge between this node and the destination with the specified options.
		# @param attributes [Hash] The associated graphviz attributes for the edge.
		def connect(destination, attributes = {})
			edge = Edge.new(@graph, self, destination, attributes)
			
			@connections << edge
			
			return edge
		end
		
		# Calculate if this node is connected to another. +O(N)+ search required.
		def connected?(node)
			return @connections.find{|edge| edge.destination == node}
		end
		
		# Add a node and #connect to it.
		# @param attributes [Hash] The associated graphviz attributes for the new node.
		def add_node(name = nil, **attributes)
			node = @graph.add_node(name, **attributes)
			
			connect(node)
			
			return node
		end
		
		def identifier
			@name
		end
		
		def dump_graph(buffer, indent, options)
			node_attributes_text = dump_attributes(@attributes)
			node_name = dump_value(self.identifier)
			
			buffer.puts "#{indent}#{node_name}#{node_attributes_text};"
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
	class Graph < Node
		# Initialize the graph with the specified unique name.
		def initialize(name = 'G', parent = nil, **attributes)
			super
			
			@edges = []
			@nodes = {}
		end
		
		# All edges in the graph
		attr :edges
		
		# @return [Array<Node>] All nodes in the graph.
		attr :nodes
		
		# @return [Array<Graph>] Any subgraphs.
		attr :graphs
		
		# @return [Hash] Any associated graphviz attributes.
		attr_accessor :attributes
		
		# @return [Node] Add a node to this graph.
		def add_node(name = nil, **attributes)
			name ||= "#{@name}N#{@nodes.count}"
			
			Node.new(name, self, attributes)
		end
		
		# Add a subgraph with a given name and attributes.
		# @return [Graph] the new graph.
		def add_subgraph(name = nil, **attributes)
			name ||= "#{@name}S#{@nodes.count}"
			
			subgraph = Graph.new(name, self, attributes)
			
			self << subgraph
			
			return subgraph
		end
		
		def << node
			@nodes[node.name] = node
			
			node.attach(self)
		end
		
		# @return [String] Output the graph using the dot format.
		def to_dot(options = {})
			buffer = StringIO.new
			
			dump_graph(buffer, "", options)
			
			return buffer.string
		end
		
		def graph_format(options)
			if @graph
				'subgraph'
			else
				options[:format] || 'digraph'
			end
		end
		
		def identifier
			if @attributes[:cluster]
				"cluster_#{@name}"
			else
				super
			end
		end
		
		def dump_edges(buffer, indent, options)
			@edges.each do |edge|
				from_name = dump_value(edge.source.identifier)
				to_name = dump_value(edge.destination.identifier)
				edge_attributes_text = dump_attributes(edge.attributes)
				
				buffer.puts "#{indent}#{from_name} #{edge} #{to_name}#{edge_attributes_text};"
			end
		end
		
		# Dump the entire graph and all subgraphs to dot text format.
		def dump_graph(buffer, indent, options)
			format = graph_format(options)
			
			buffer.puts "#{indent}#{format} #{dump_value(self.identifier)} {"
			
			@attributes.each do |(name, value)|
				buffer.puts "#{indent}\t#{name}=#{dump_value(value)};"
			end
			
			@nodes.each do |(name, node)|
				node.dump_graph(buffer, indent + "\t", options)
			end
			
			dump_edges(buffer, indent + "\t", options)
			
			buffer.puts "#{indent}}"
		end
	end
end
