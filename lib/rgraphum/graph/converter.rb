# -*- coding: utf-8 -*-

class Rgraphum::Graph
  attr_accessor :directed
end

class Rgraphum::Graph::Converter

  class << self

    def to_undirected(pre_graph)
      graph = pre_graph.dup
      start_edge_id = graph.edges.id.max

      return graph if pre_graph.directed

      pre_graph.edges.each do |pre_edge|
        edge        = pre_edge.dup
        edge.source = pre_edge.target
        edge.target = pre_edge.source
        edge.id     = edge.id + start_edge_id
        graph.edges.build(edge)
      end

      graph.directed = false
      graph
    end

  end

end
