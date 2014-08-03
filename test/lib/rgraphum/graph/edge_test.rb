# -*- coding: utf-8 -*-

require 'rgraphum'
require 'test_helper'

class RgraphumEdgeTest < MiniTest::Unit::TestCase
  def setup
    @graph = Rgraphum::Graph.new
    @graph.vertices << { id: 1, label: "hoge" }
    @graph.vertices << { id: 2, label: "huga" }

    @vertex0, @vertex1 = @graph.vertices

    @vertex0.edges << { source: @vertex0, target: @vertex1 }

    @edge0 = @graph.edges[0]
  end

  def test_vertex_within_term
    t = Time.now
    vertex_a = Rgraphum::Vertex()
    vertex_a.start = t
    vertex_a.end   = t + 2

    vertex_b = Rgraphum::Vertex()
    vertex_b.start = t + 1
    vertex_b.end   = t + 3

    assert_equal true,  vertex_a.within_term(vertex_b)
    assert_equal false, vertex_b.within_term(vertex_a)
  end

  def test_invalid_source
    v1 = Rgraphum::Vertex.new(label: "1")
    v2 = Rgraphum::Vertex.new(label: "2")

    assert_raises(ArgumentError) do
      Rgraphum::Edge(target: v2, label: "label")
    end

    assert_raises(ArgumentError) do
      Rgraphum::Edge(source: nil, target: v2, label: "label")
    end
  end

  def test_invalid_target
    v1 = Rgraphum::Vertex.new(label: "1")
    v2 = Rgraphum::Vertex.new(label: "2")

    assert_raises(ArgumentError) do
      Rgraphum::Edge(source: v1, label: "label")
    end

    assert_raises(ArgumentError) do
      Rgraphum::Edge(source: v1, target: nil, label: "label")
    end
  end
end
