# -*- coding: utf-8 -*-

require 'rgraphum'
require 'test_helper'

class RgraphumDupTest < MiniTest::Unit::TestCase
  def setup
    @graph = Rgraphum::Graph.new
    @graph.vertices << { id: 1, label: "hoge" }
    @graph.vertices << { id: 2, label: "huga" }
    @graph.vertices << { id: 3, label: "piyo" }

    vertices = @graph.vertices
    @graph.edges << { id: 1, source: vertices[0], target: vertices[1], weight: 1 }
    @graph.edges << { id: 2, source: vertices[1], target: vertices[2], weight: 1 }
    @graph.edges << { id: 3, source: vertices[2], target: vertices[0], weight: 1 }

    @vertex_0 = @graph.vertices[0]
  end

  def test_edge_dup
    edge_dup = @vertex_0.edges[0].dup

    assert       @vertex_0.edges[0].object_id != edge_dup.object_id, "#{@vertex_0.edges[0].object_id} is equal #{edge_dup.object_id} "
    assert_equal @vertex_0.edges[0],           edge_dup
  end

  def test_vertex_edges_dup
    edges_dup = @vertex_0.edges.dup

    assert_equal @vertex_0.edges, edges_dup
    assert_nil   edges_dup.graph
    assert_nil   edges_dup.vertex

    edges_dup.each_with_index do |edge,i|
      assert_equal edge, @vertex_0.edges[i]
      refute_same edge, @vertex_0.edges[i]
    end
  end

  def test_vertex_dup
    #  1:hoge --- 2:huga
    #    \        /
    #     \      /
    #     3:piyo

    #  1:hoge----------|
    #   \ 1':hoge --- 2:huga
    #    \    |     /
    #     \   |    /
    #      \  |   /
    #       3:piyo

    vertex = @vertex_0.dup

    assert_instance_of Rgraphum::Vertex, vertex
    refute_same   vertex,  @vertex_0
    refute_same   vertex.rgraphum_id, @vertex_0.rgraphum_id

    assert_equal  [], vertex.edges

  end

  def test_graph_edges_dup
    edges_dup = @graph.edges.dup

    assert_equal @graph.edges, edges_dup
    refute_same  @graph.edges, edges_dup
    assert_nil edges_dup.graph
    assert_nil edges_dup.vertex

    @graph.vertices.each do |vertex|
      edges_dup = vertex.edges.dup
      refute_same vertex.edges, edges_dup
      assert_nil edges_dup.graph
      assert_nil edges_dup.vertex
    end
  end

  def test_graph_dup
    duped_graph = @graph.dup

    assert_instance_of Rgraphum::Graph, duped_graph
    refute_same  duped_graph, @graph

    assert_equal duped_graph.vertices, @graph.vertices
    refute_same  duped_graph.vertices, @graph.vertices

    assert_equal duped_graph.edges, @graph.edges
    refute_same  duped_graph.edges, @graph.edges


    @graph.vertices.each_with_index do |vertex, vertex_index|
      duped_vertex = duped_graph.vertices[vertex_index]

      assert_equal duped_vertex, vertex
      refute_same  duped_vertex, vertex
      refute_same  duped_vertex.rgraphum_id, vertex.rgraphum_id

      vertex.edges.each_with_index do |edge,edge_index|
        duped_edge = duped_vertex.edges[edge_index]

        assert_equal duped_edge, edge
        refute_same  duped_edge, edge

        assert_equal duped_edge.source, edge.source
        refute_same  duped_edge.source, edge.source
        assert_same  duped_graph.vertices.where(id: duped_edge.source.id).first, duped_edge.source

        assert_equal duped_edge.target, edge.target
        refute_same  duped_edge.target, edge.target
      end
    end

    @graph.edges.each_with_index do |edge,edge_index|
      duped_edge = duped_graph.edges[edge_index]

      assert_equal duped_edge, edge
      refute_same  duped_edge, edge
    end
  end
end
