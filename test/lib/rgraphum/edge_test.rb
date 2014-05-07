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

  def test_find_vertices_for_source_and_target
    source_vertex = @edge0.find_vertex(:source, @graph.vertices)
    p source_vertex if Rgraphum.verbose?
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

  def test_edge_dump_and_load
    vertex1 = Rgraphum::Vertex.new(id: 1, label: "vertex 1")
    vertex2 = Rgraphum::Vertex.new(id: 2, label: "vertex 2")
    edge  = Rgraphum::Edge.new({source: vertex1, target: vertex2})

    data = Marshal.dump(edge)
    edge_dash = Marshal.load(data)

    assert_equal edge, edge_dash
    assert_equal edge.source, edge_dash.source
    assert_equal edge.target, edge_dash.target
  end

#  def test_invalid_field
#    v1 = Rgraphum::Vertex.new(label: "1")
#    v2 = Rgraphum::Vertex.new(label: "2")
#
#    assert_raises(ArgumentError) do
#      Rgraphum::Edge.new(source: v1, target: v2, labeeeeeeeeeeeeeeeeeeeel: "label")
#    end
#
#    assert_raises(ArgumentError) do
#      Rgraphum::Edge.new(source: v1, target: v2, label: "label", labeeeeeeeeeeeeeeeeeeeel: "label")
#    end
#  end

  def test_invalid_source
    v1 = Rgraphum::Vertex.new(label: "1")
    v2 = Rgraphum::Vertex.new(label: "2")

    assert_raises(ArgumentError) do
      Rgraphum::Edge.new(target: v2, label: "label")
    end

    assert_raises(ArgumentError) do
      Rgraphum::Edge.new(source: nil, target: v2, label: "label")
    end
  end

  def test_invalid_target
    v1 = Rgraphum::Vertex.new(label: "1")
    v2 = Rgraphum::Vertex.new(label: "2")

    assert_raises(ArgumentError) do
      Rgraphum::Edge.new(source: v1, label: "label")
    end

    assert_raises(ArgumentError) do
      Rgraphum::Edge.new(source: v1, target: nil, label: "label")
    end
  end
end
