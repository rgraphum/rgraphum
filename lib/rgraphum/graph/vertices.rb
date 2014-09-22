# -*- coding: utf-8 -*-

def Rgraphum::Vertices(array)
  if array.instance_of?(Rgraphum::Vertices)
    array
  else
    Rgraphum::Vertices.new(array)
  end
end

class Rgraphum::Vertices < Rgraphum::Elements
  include Rgraphum::RgraphumArrayDividers

  def initialize(vertices=[])
    @rgraphum_id = new_rgraphum_id
    vertices.each do |vertex|
      self << vertex
    end
  end

  def [](index)
    id = id_rgraphum_id_hash.keys[index]
    rgraphum_id = id_rgraphum_id_hash[id]
    vertex = Rgraphum::Vertex.new
    vertex.rgraphum_id = rgraphum_id.to_i
    vertex.graph = @graph if @graph
    vertex
  end

  def size
    id_rgraphum_id_hash.size
  end

  def find_by_id(id)
    tmp_id = id_rgraphum_id_hash[id.to_s]
    vertex = Rgraphum::Vertex.new
    vertex.rgraphum_id = tmp_id.to_i
    vertex.graph = @graph
    vertex.reload
  end

  def build(vertex_hash)
    vertex = Rgraphum::Vertex(vertex_hash)
    vertex.graph = @graph
    vertex.id = new_id(vertex[:id],vertex.rgraphum_id)
    original_push_1(vertex)
    vertex
  end

  alias :original_push_1 :<<
  def <<(vertex_hash)
    build(vertex_hash)
    self
  end

  alias :original_push_m :push
  def push(*vertex_hashs)
    vertex_hashs.each do |vertex_hash|
      build(vertex_hash)
    end
    self
  end

  # Called from delete_if, reject! and reject
  def delete(vertex_or_id)
    id = vertex_or_id.id rescue vertex_or_id
    target_vertex = find_by_id(id)
    target_vertex.edges.ids.each { |id| target_vertex.edges.delete(id) }

    Redis.current.hdel( @rgraphum_id,id )
    ElementManager.delete( target_vertex.rgraphum_id )
  end

  def to_community
    Rgraphum::Community.new(vertices: self)
  end

  def to_graph
    to_community.to_graph
  end

  protected :original_push_1
  protected :original_push_m
end
