# -*- coding: utf-8 -*-

require 'rgraphum'
require 'test_helper'

class RgraphumVertexTest < MiniTest::Test
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
    vertex_a = Rgraphum::Vertex.new
    vertex_a.start = t
    vertex_a.end   = t + 2

    vertex_b = Rgraphum::Vertex.new
    vertex_b.start = t + 1
    vertex_b.end   = t + 3

    assert_equal true,  vertex_a.within_term(vertex_b)
    assert_equal false, vertex_b.within_term(vertex_a)
  end

  def test_vertex_dump_and_load
    vertex = Rgraphum::Vertex.new(id: 1, label: "vertex 1")

    data = Marshal.dump(vertex)
    vertex_dash = Marshal.load(data)

    rg_assert_equal vertex, vertex_dash
  end

  def test_invalid_field
    assert_raises(ArgumentError) do
      Rgraphum::Vertex.new(labeeeeeeeeeeeeeeeeeeeel: "label")
    end

    assert_raises(ArgumentError) do
      Rgraphum::Vertex.new(label: "label", labeeeeeeeeeeeeeeeeeeeel: "label")
    end
  end
end
