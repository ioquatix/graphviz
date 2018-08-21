#!/usr/bin/env ruby

require_relative '../lib/graphviz'

# Hello
#   |
# People

hello = Graphviz::Graph.new("Hello")
keywords = []
keywords[0] = hello.add_node("Hello")
keywords[1] = hello.add_node("People")

# We link Hello to People
hello_people = keywords[0].connect(keywords[1])

#      People
#   /    |    \
#  Bob  Jim   Kev

people = Graphviz::Graph.new("People")
persons = []
persons[0] = people.add_node("Bob")
persons[1] = people.add_node("Jim")
persons[2] = people.add_node("Kev")

# We link people (People = {Bob, Jim, Kev})
people_bob = keywords[1].connect(persons[0])
people_jim = keywords[1].connect(persons[1])
people_kev = keywords[1].connect(persons[2])

# Attributes for "Hello"
keywords[0].attributes[:shape] = 'box3d'
keywords[0].attributes[:color] = 'red'

# Generate the Graph (pdf format)
Graphviz::output(hello, :path => "test.pdf")
