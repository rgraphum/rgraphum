# -*- coding: utf-8 -*-

require 'rgraphum'
require 'test_helper'

class RgraphumPlusTest < MiniTest::Unit::TestCase
  def setup
    @graph_a = Rgraphum::Graph.new
    @graph_a.vertices = [
      { id: 1, label: "hoge" },
      { id: 2, label: "huga" },
    ]
    vertices_a = @graph_a.vertices
    @graph_a.edges << { id: 1, source: vertices_a[0], target: vertices_a[1], weight: 1}
    @graph_a.edges << { id: 2, source: vertices_a[1], target: vertices_a[0], weight: 1}

    @graph_b = Rgraphum::Graph.new
    vertices_b = @graph_b.vertices = [
      { id: 1, label: "piyo" },
      { id: 2, label: "hogeratte" },
    ]
    vertices_b = @graph_b.vertices
    @graph_b.edges << { id: 1, source: vertices_b[0], target: vertices_b[1], weight: 1 }
    @graph_b.edges << { id: 2, source: vertices_b[1], target: vertices_b[0], weight: 1 }
  end

  def test_add
    added_graph = @graph_a + @graph_b

    assert_instance_of Rgraphum::Graph, added_graph
    assert_equal [1,2,3,4], added_graph.vertices.id

    refute_same @graph_a,       added_graph
    refute_same @graph_a.edges, added_graph.edges
    refute_same @graph_b,       added_graph
    refute_same @graph_b.edges, added_graph.edges

    @graph_a.vertices.each_with_index do |vertex, vertex_index|
      added_vertex = added_graph.vertices[vertex_index]

      assert_equal vertex.object_id, added_vertex.object_id
      refute_same  vertex, added_vertex

      vertex.edges.each_with_index do |edge, edge_index|
        added_edge = added_vertex.edges[edge_index]

        rg_assert_equal edge, added_edge
        refute_same  edge, added_edge

        rg_assert_equal edge.source,       added_edge.source
        refute_same  edge.source,       added_edge.source
        assert_same  added_edge.source, added_graph.vertices.where(id: added_edge.source.id).first

        rg_assert_equal edge.target,       added_edge.target
        refute_same  edge.target, added_edge.target
      end
    end

    @graph_b.vertices.each_with_index do |vertex, vertex_index|
      added_vertex = added_graph.vertices[vertex_index + 2]

      refute_same  vertex,       added_vertex

      vertex.edges.each_with_index do |edge, edge_index|
        added_edge = added_vertex.edges[edge_index]

        refute_same edge, added_edge

        assert_equal edge.id + 2,        added_edge.id

        refute_same  edge.source,        added_edge.source
        assert_same  added_edge.source,  added_graph.vertices.where(id: added_edge.source.id).first

        assert_equal edge.target.id + 2, added_edge.target.id
        assert_equal edge.target.label,  added_edge.target.label
        refute_same  edge.target,        added_edge.target
      end
    end
  end
end
