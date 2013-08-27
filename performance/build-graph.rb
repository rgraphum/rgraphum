#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require_relative '../lib/rgraphum'

graph = Rgraphum::Graph.new

size = 30000

size.times do |n|
  graph.vertices.build(label: "v#{n+1}")
end

(0...size).step(10).each do |n|
  v = graph.vertices[n]
  ((n+1)...(n+10)).each do |i|
    graph.edges.build(source: v, target: graph.vertices[i])
  end
end
