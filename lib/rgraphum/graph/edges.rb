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

  def find_by_id(id)
    tmp_id = id_rgraphum_id_hash[id.to_s]
    edge = Rgraphum::Edge.new
    edge.rgraphum_id = tmp_id.to_i
    edge.graph = @graph
    edge
    @id_edge_map[id]
  end

  def to_hash
    ElementManager.load(rgraphum_id)
  end
  alias :to_h :to_hash  


  def find_vertex(vertex)
    @graph.vertices.find_by_id(vertex)
  end

  def build(edge_or_hash, recursive=true)
    if @vertex and @vertex.graph
      edge = Rgraphum::Edge(edge_or_hash)

      if recursive
        edge = @vertex.graph.edges.build(edge_or_hash, false)
      else
        edge = edge_or_hash
        original_push_1 edge
      end
    else
      edge = Rgraphum::Edge(edge_or_hash)
      if @graph
        edge.graph = @graph

        raise ArgumentError, "Source vertex is required" unless edge.source
        raise ArgumentError, "Target vertex is required" unless edge.target

        edge.id = new_id(edge.id,edge.rgraphum_id)

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
  alias :original_delete :delete
  def delete(edge_or_id)
    id = edge_or_id.id rescue edge_or_id
    edge = find_by_id(id)

    return edge_or_id unless edge

    edge.source.edges.original_delete(edge)
    edge.source.out_edges.original_delete(edge)

    edge.target.edges.original_delete(edge)
    edge.target.in_edges.original_delete(edge)

    edge.graph.edges.original_delete(edge)   
    
    ElementManager.delete(edge.rgraphum_id)

    edge
  end

  protected :original_push_1
  protected :original_push_m

  private
end
