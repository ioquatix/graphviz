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

require_relative 'node'

module Graphviz
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
		
		# Finds all nodes with a given name
		#
		# @param [String] node_name the name to look for
		# @return [Array<Graphviz::Node>, nil] list of all found nodes or nil
		def get_node(node_name)
			@nodes.select{ |k, v| v.name == node_name}.values
		end

		# Determines if a node with a given name exists in the graph
		#
		# @param [String] node_name the name to look for
		# @return [Boolean] if node exists in graph
		def node_exists?(node_name)
			@nodes.select{ |k, v| v.name == node_name}.any?
		end


		def << node
			@nodes[node.name] = node
			
			node.attach(self)
		end
		
		# @return [String] Output the graph using the dot format.
		def to_dot(**options)
			buffer = StringIO.new
			
			dump_graph(buffer, **options)
			
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
		
		def dump_edges(buffer, indent, **options)
			@edges.each do |edge|
				edge_attributes_text = dump_attributes(edge.attributes)
				
				buffer.puts "#{indent}#{edge}#{edge_attributes_text};"
			end
		end
		
		# Dump the entire graph and all subgraphs to dot text format.
		def dump_graph(buffer, indent = "", **options)
			format = graph_format(options)
			
			buffer.puts "#{indent}#{format} #{dump_value(self.identifier)} {"
			
			@attributes.each do |name, value|
				buffer.puts "#{indent}\t#{name}=#{dump_value(value)};"
			end
			
			@nodes.each do |name, node|
				node.dump_graph(buffer, indent + "\t", options)
			end
			
			dump_edges(buffer, indent + "\t", options)
			
			buffer.puts "#{indent}}"
		end
	end
end
