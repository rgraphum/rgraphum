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

  def initialize(vertex_hashes=[])
    ids = vertex_hashes.each { |vertex| vertex.id }
    super(ids)
    @id_vertex_map = {}
  end

  def find_by_id(id)
    tmp_id = id_rgraphum_id_hash[id.to_s]
    vertex = Rgraphum::Vertex.new
    vertex.rgraphum_id = tmp_id.to_i
    vertex.graph = @graph
    vertex

    @id_vertex_map[id]
  end

  # FIXME use initialize_copy instead
  def dup
    edges = map{ |vertex| vertex.edges }.flatten.uniq
    vertices = super
    vertices.graph = nil
    vertices.each {|vertex| vertex.edges = Rgraphum::Edges.new }

    vertices
  end

  def build(vertex_hash)
    vertex = Rgraphum::Vertex(vertex_hash)
    vertex.graph = @graph
    vertex.id = new_id(vertex[:id],vertex.rgraphum_id)
    original_push_1(vertex)
    @id_vertex_map[vertex.id] = vertex
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
    unless target_vertex.edges.empty?
      target_vertex.edges.reverse_each do |edge|
        target_vertex.edges.delete(edge)
      end
    end
    @id_vertex_map.delete id
    super(target_vertex)
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
