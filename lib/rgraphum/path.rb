# -*- coding: utf-8 -*-

class Rgraphum::Path
  attr_reader :end_vertex
  attr_reader :vertices

  # vertices:      Array of Rgraphum::Vertex
  #
  def initialize(end_vertex=nil, vertices=[])
    @end_vertex = end_vertex
   @vertices   = vertices
  end

  def include?(vertex)
    vertices.include?(vertex)
  end

  def edges
    # FIXME
    last_vertex = vertices.first
    graph = last_vertex.graph
    new_edges = []
    vertices.each do |vertex|
      if last_vertex != vertex
        edge   = graph.edges.where(source: last_vertex, target: vertex).first
        edge ||= graph.edges.where(source: vertex, target: last_vertex).first
        new_edges << edge
      end
      last_vertex = vertex
    end
   new_edges
  end

  def total_weight
   edges.inject(0) { |sum, edge| sum + edge.weight }
  end
end
