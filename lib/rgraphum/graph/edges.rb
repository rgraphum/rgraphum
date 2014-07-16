# -*- coding: utf-8 -*-

def Rgraphum::Edges(array)
  if array.instance_of?(Rgraphum::Edges)
    array
  else
    Rgraphum::Edges.new(array)
  end
end

class Rgraphum::Edges < Rgraphum::Elements
  include Rgraphum::RgraphumArrayDividers

  attr_accessor :vertex

  def initialize(edge_hashes=[])
    super()
    @id_edge_map = {}
    edge_hashes.each do |edge_hash|
      self << edge_hash
    end
  end

  def find_by_id(edge_id)
    if edge_id.is_a?(Rgraphum::Edge)
      id = edge_id.id
    else
      id = edge_id
    end
    @id_edge_map[id]
  end

  def find_vertex(vertex)
    if vertex.is_a?(Rgraphum::Vertex) and vertex.graph.equal?(@graph)
      vertex
    else
      @graph.vertices.find_by_id(vertex)
    end    
  end

  def build(edge_or_hash, recursive=true)
    if @vertex and @vertex.graph
      if recursive
        edge = @vertex.graph.edges.build(edge_or_hash, false)
      else
        edge = edge_or_hash
        original_push_1 edge
      end
    else
      edge = Rgraphum::Edge(edge_or_hash)
      if @graph
        source_vertex = find_vertex(edge.source)
        target_vertex = find_vertex(edge.target)
        raise ArgumentError, "Source vertex is required" unless source_vertex
        raise ArgumentError, "Target vertex is required" unless target_vertex
        edge.source = source_vertex
        edge.target = target_vertex

        edge.id = new_id(edge.id)
        edge.graph = @graph

        edge.source.edges.build(edge, false)
        edge.source.out_edges.build(edge, false)

        edge.target.edges.build(edge, false)
        edge.target.in_edges.build(edge, false)
      end
      original_push_1 edge
    end

    @id_edge_map[edge.id] = edge

    edge
  end

  alias :original_push_1 :<<
  def <<(edge_or_hash)
    build(edge_or_hash)
    self
  end

  alias :original_push_m :push
  def push(*edge_hashes)
    edge_hashes.each do |edge_hash|
      build(edge_hash)
    end
    self
  end

  # Called from delete_if, reject! and reject
  def delete(edge_or_id, recursive=true)
    id = edge_or_id.id rescue edge_or_id
    target_edge = find_by_id(id)

    return edge_or_id unless target_edge
    deleted_edge = super(target_edge)

    if @vertex and @vertex.graph
      if recursive
        @vertex.graph.edges.delete(target_edge, false)
      end
    else
      if @graph
        target_edge.source.edges.delete(target_edge, false)
        target_edge.source.out_edges.delete(target_edge, false)

        target_edge.target.edges.delete(target_edge, false)
        target_edge.target.in_edges.delete(target_edge, false)
      end
    end
    @id_edge_map.delete id

    deleted_edge
  end

#  def weights
#    self.map{ |edge| edge.weight }
#  end

  protected :original_push_1
  protected :original_push_m

  private
end
