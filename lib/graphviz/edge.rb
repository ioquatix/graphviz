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
			"#{@source} -> #{@destination}"
		end
	end
end
