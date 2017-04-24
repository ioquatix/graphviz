
RSpec.describe Graphviz::Edge do
	let(:graph) {Graphviz::Graph.new}
	
	let(:a) {Graphviz::Node.new(:a, graph)}
	let(:b) {Graphviz::Node.new(:b, graph)}
	
	describe '#to_s' do
		subject{a.connect(b)}
		
		it 'should generate edge string' do
			expect(subject.to_s).to be == 'a -> b'
		end
	end
end
