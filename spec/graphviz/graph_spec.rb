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

require 'graphviz'

RSpec.describe Graphviz::Graph do
	let(:sample_graph_dot) do
		<<~EOF
			digraph "G" {
				"Foo"[shape="box3d", color="red"];
				"Bar";
				"Foo" -> "Bar";
			}
		EOF
	end
	
	it "should construct a simple graph" do
		foo = subject.add_node("Foo")
		foo.add_node("Bar")

		foo.attributes[:shape] = 'box3d'
		foo.attributes[:color] = 'red'

		expect(subject.to_dot).to be == sample_graph_dot

		# Process the graph to output:
		Graphviz::output(subject, :path => "test.pdf")

		expect(File.exist? "test.pdf").to be true
	end

	it "gets a node" do
		foo = subject.add_node('Foo')
		bar = subject.add_node('Bar')
		bar.add_node('Baz')
		expect(subject.get_node('Baz')).to be_an(Array)
		expect(subject.get_node('Baz').size).to eq 1
		expect(subject.get_node('Foo').first).to be_a(Graphviz::Node)
		expect(subject.get_node('Nothing')).to be_an(Array)
		expect(subject.get_node('Nothing').size).to eq 0
end

	it "checks if a node exists" do
		foo = subject.add_node('Foo')
		bar = subject.add_node('Bar')
		bar.add_node('Baz')
		expect(subject.node_exists?('Baz')).to be true
		expect(subject.node_exists?('Nothing')).to be false
	end

	it 'should raise an error the executable is installed' do
		expect do
			Graphviz.output(subject, :dot => 'foobarbaz')
		end.to raise_error(Errno::ENOENT, 'No such file or directory - foobarbaz')
	end
end
