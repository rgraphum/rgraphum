#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require_relative '../../lib/rgraphum'

graph = Rgraphum::Graph.new()
graph.vertices = [ {id:1,label:"1"},{id:2,label:"2"},{id:3,label:"3"} ]
graph.edges = [ {id:1,source:1,target:2,weight:1},{id:2,source:2,target:3,weight:1},{id:3,source:3,target:1,weight:1}]
json = graph.to_miserables
file = File.open(  "public/miserables.js", "w+" )
file.write(json)

