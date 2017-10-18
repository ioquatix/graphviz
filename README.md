# Graphviz

Graphviz is a graph visualisation system. This gem is a lightweight interface for generating graphs with Graphviz.

[![Build Status](https://travis-ci.org/ioquatix/graphviz.svg)](https://travis-ci.org/ioquatix/graphviz)
[![Coverage Status](https://coveralls.io/repos/ioquatix/graphviz/badge.svg)](https://coveralls.io/r/ioquatix/graphviz)

## Installation

Add this line to your application's Gemfile:

	gem 'graphviz'

And then execute:

	$ bundle

Or install it yourself as:

	$ gem install graphviz

## Usage

Some example code:

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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Released under the MIT license.

Copyright, 2013, by [Samuel G. D. Williams](http://www.codeotaku.com/samuel-williams).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
