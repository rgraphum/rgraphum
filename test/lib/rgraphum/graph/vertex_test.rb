# -*- coding: utf-8 -*-

require 'rgraphum'
require 'test_helper'

class RgraphumVertexTest < MiniTest::Unit::TestCase
  def setup
    @graph = Rgraphum::Graph.new
    @graph.vertices = [
      { id: 1, label: "hoge" },
      { id: 2, label: "huga" },
    ]

    @vertex0 = @graph.vertices[0]
    @vertex1 = @graph.vertices[1]
  end

  def test_vertex_within_term
    t = Time.now
    vertex_a = Rgraphum::Vertex()
    vertex_a.start = t
    vertex_a.end   = t + 2

    vertex_b = Rgraphum::Vertex()
    vertex_b.start = t + 1
    vertex_b.end   = t + 3

    vertex_b

    assert_equal true,  vertex_a.within_term(vertex_b)
    assert_equal false, vertex_b.within_term(vertex_a)
  end

  def test_vertex_dump_and_load
    vertex = Rgraphum::Vertex(id: 1, label: "vertex 1")

    data = Marshal.dump(vertex)
    vertex_dash = Marshal.load(data)

    assert_equal vertex, vertex_dash
  end

  def test_vertex_dup
    other = @vertex0.dup
    
    @vertex0.each do |key,value|
       assert_equal value, other[key]
    end

    refute_equal @vertex0.rgraphum_id,        other.rgraphum_id
    refute_equal @vertex0.edges.rgraphum_id,  other.edges.rgraphum_id

    

  end

end
