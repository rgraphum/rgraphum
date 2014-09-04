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
    assert_equal [1,2,3,4], added_graph.edges.id

    refute_same @graph_a.object_id,       added_graph.object_id
    refute_same @graph_b.object_id,       added_graph.object_id

    @graph_a.vertices.each_with_index do |vertex, vertex_index|
      added_vertex = added_graph.vertices[vertex_index]

      refute_same vertex, added_vertex
      refute_same vertex.rgraphum_id,  added_vertex.rgraphum_id

      vertex.edges.each_with_index do |edge, edge_index|
        added_edge = added_vertex.edges[edge_index]

        assert_equal edge.reload, added_edge.reload
        refute_same  edge, added_edge

        assert_equal edge.source.reload,      added_edge.source.reload
        refute_same  edge.source.rgraphum_id, added_edge.source.rgraphum_id
        assert_same  added_edge.source,  added_graph.vertices.where(id: added_edge.source.id).first

        assert_equal edge.target.reload,       added_edge.target.reload
        refute_same  edge.target.rgraphum_id,  added_edge.target.rgraphum_id
      end
    end

    @graph_b.vertices.each_with_index do |vertex, vertex_index|
      added_vertex = added_graph.vertices[vertex_index + 2]

      refute_same  vertex,       added_vertex

      vertex.edges.each_with_index do |edge, edge_index|
        added_edge = added_vertex.edges[edge_index]


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
