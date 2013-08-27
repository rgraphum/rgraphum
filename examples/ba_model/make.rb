#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require_relative '../../lib/rgraphum'
require 'csv'
require 'time'

include Rgraphum
p start_time = Time.now

graph = Graph.new
after_graph = graph.simulate("BAModel",:round =>100 )
after_graph.dump_to("./examples/ba_model/test.rgraphum")

p Time.now - start_time

file = File.open( File.dirname(__FILE__) + "/test.gexf", "w+" )
file.write( after_graph.to_gephi )

