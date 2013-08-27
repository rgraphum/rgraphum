#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require_relative '../lib/rgraphum'

graph = Rgraphum::Graph.new

size = (ARGV.shift || 1000).to_i

size.times do |n|
  graph.vertices.build(label: "v#{n+1}")
end
