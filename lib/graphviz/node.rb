# Copyright, 2017, by Samuel G. D. Williams. <http://www.codeotaku.com>
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

require_relative 'edge'

module Graphviz
	# Represents a visual node in the graph, which can be connected to other nodes.
	class Node
		# Initialize the node in the graph with the unique name.
		# @param attributes [Hash] The associated graphviz attributes for this node.
		def initialize(name, graph = nil, **attributes)
			@name = name
			@attributes = attributes
			
			@connections = []
			
			# This sets up the connection between the node and the parent.
			@graph = nil
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
		
		def to_s
			dump_value(@name)
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
				"[" + attributes.collect{|name, value| "#{name}=#{dump_value(value)}"}.join(", ") + "]"
			else
				""
			end
		end
	end
end
