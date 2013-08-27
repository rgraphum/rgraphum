#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require_relative '../lib/rgraphum'

graph = Rgraphum::Graph.new

size = (ARGV.shift || 1000).to_i

size.times do |n|
  graph.vertices.build(label: "v#{n+1}")
end

size.times do |n1|
  n2 = n1 + 1
  n2 = 0 if n2 == size
  v1 = graph.vertices[n1]
  v2 = graph.vertices[n2]
  graph.edges.build(source: v1, target: v2, weight: 1)
end

size.times do |n|
  vertex = graph.vertices[rand(graph.vertices.size)]
  graph.vertices.delete vertex
end
