#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require_relative '../../lib/rgraphum'

include Rgraphum

graph = Rgraphum::Graph.new

# add vertices
graph.vertices << {id:1,name:"marko", age:29            }
graph.vertices << {id:2,name:"vadas", age:27            }
graph.vertices << {id:3,name:"lop",          lang:"java"}
graph.vertices << {id:4,name:"josh",  age:32            }
graph.vertices << {id:5,name:"ripple",       lang:"java"}
graph.vertices << {id:6,name:"peter", age:35}

# add vertices
graph.edges << {id:7, label:"knows",  weight:0.5,source:1,target:2}
graph.edges << {id:8, label:"knows",  weight:1.0,source:1,target:4}
graph.edges << {id:9, label:"created",weight:0.4,source:1,target:3}
graph.edges << {id:10,label:"created",weight:1.0,source:4,target:5}
graph.edges << {id:11,label:"created",weight:0.4,source:4,target:3}

#graph.to_graphviz
p Rgraphum::Parsers::GraphvizParser.new.export(graph, File.dirname(__FILE__) + "/hoge","jpg")


