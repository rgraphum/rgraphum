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

  def initialize(edges=[])
    @rgraphum_id = new_rgraphum_id
    edges.each do |edge|
      self << edge
    end
  end

  def each
    if block_given?
      id_rgraphum_id_hash.values.each do |rgraphum_id|
        edge = Rgraphum::Edge.new
        edge.rgraphum_id = rgraphum_id
        edge.graph = @graph  if @graph
        edge.graph = @vertex.graph if @vertex
        yield edge
      end
    else
      to_enum
    end
  end


  def find_by_id(id)
    tmp_id = id_rgraphum_id_hash[id.to_s]
    edge = Rgraphum::Edge.new
    edge.rgraphum_id = tmp_id.to_i
    edge.graph = @graph || @vertex.graph
    edge
  end


  def find_vertex(vertex)
    @graph.vertices.find_by_id(vertex)
  end

  def build(edge_or_hash, recursive=true)
    return @graph.add_edge(edge_or_hash) if @graph
    return @vertex.graph.add_edge(edge_or_hash) if @vertex and @vertex.graph
    return push_with_rgraphum_id(edge_or_hash)
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

  def push_with_rgraphum_id(edge) 
    elements_manager.add_id(edge.id,edge.rgraphum_id)
    original_push_1 (edge)
  end

  # Called from delete_if, reject! and reject
  alias :original_delete :delete
  def delete(edge_or_id)

    id = edge_or_id.id rescue edge_or_id
    edge = find_by_id(id)

    return edge_or_id unless edge

    edge.source.edges.original_delete_if { |item| item.rgraphum_id == edge.rgraphum_id }
    edge.source.out_edges.original_delete_if { |item| item.rgraphum_id == edge.rgraphum_id }

    edge.target.edges.original_delete_if { |item| item.rgraphum_id == edge.rgraphum_id }
    edge.target.in_edges.original_delete_if { |item| item.rgraphum_id == edge.rgraphum_id }

    edge.graph.edges.original_delete_if { |item| item.rgraphum_id == edge.rgraphum_id }

    ElementManager.delete(edge.rgraphum_id)

    edge
  end

  protected :original_push_1
  protected :original_push_m

  private
end
