#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require_relative '../../lib/rgraphum'

#  1 - 2 
#  #   \ /
#  #    3
#  #   / \
#  #  4 - 5
#   

graph = Rgraphum::Graph.new
graph.vertices = [{id:1,label:"A"},
               {id:2,label:"B"},
               {id:3,label:"C"},
               {id:4,label:"D"},
               {id:5,label:"E"}]

graph.edges = [{id:0,source:1,target:2,weight:1},
               {id:1,source:1,target:3,weight:1},
               {id:2,source:2,target:3,weight:1},
               {id:3,source:3,target:4,weight:1},
               {id:4,source:3,target:5,weight:1},
               {id:5,source:4,target:5,weight:1}] # !> assigned but unused variable - i

p graph.modularity # => 0.1111111111111111
