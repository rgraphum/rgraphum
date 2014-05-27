# -*- coding: utf-8 -*-

class Rgraphum::Graph
  attr_accessor :directed
end

class Rgraphum::Graph::Converter

  class << self

    def to_undirected(pre_graph)
      graph = pre_graph.dup
      return graph if pre_graph.directed

      pre_graph.edges.each do |pre_edge|
        edge   = pre_edge.dup
        edge[:source] = pre_edge[:target]
        edge[:target] = pre_edge[:source]
        graph.edges.build(edge)
      end

      graph.directed = false
      graph
    end

#    def directed(graph)
#      graph
#    end
  end

end
