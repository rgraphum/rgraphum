# -*- coding: utf-8 -*-

require 'rgraphum'
require 'test_helper'

class RgraphumDupTest < MiniTest::Test
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

    refute_same @vertex_0.edges[0], edge_dup
  end

  def test_vertex_edges_dup
    edges_dup = @vertex_0.edges.dup

    refute_same @vertex_0.edges, edges_dup
    assert_nil edges_dup.graph
    assert_nil edges_dup.vertex

    edges_dup.each_with_index do |edge,i|
      rg_assert_equal edge, @vertex_0.edges[i]
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

    refute_empty  vertex.edges
    rg_assert_equal  vertex.edges.vertex,   vertex

    assert_same   vertex.edges.vertex, vertex

    refute_same  vertex.edges, @vertex_0.edges
    vertex.edges.each_with_index do |edge,i|
      rg_assert_equal     edge,           @vertex_0.edges[i]
      refute_same edge, @vertex_0.edges[i]

      rg_assert_equal vertex, edge.source    unless edge.target == vertex
      rg_assert_equal vertex, edge.target    unless edge.source == vertex
      rg_assert_equal @vertex_0, @vertex_0.edges[i].source unless @vertex_0.edges[i].target == @vertex_0
      rg_assert_equal @vertex_0, @vertex_0.edges[i].target unless @vertex_0.edges[i].source == @vertex_0

      assert       (edge.source.object_id == vertex.object_id or edge.target.object_id == vertex.object_id)
      assert_same vertex, edge.source unless edge.target.object_id == vertex.object_id
      assert_same vertex, edge.target unless edge.source.object_id == vertex.object_id
    end

    # vertex.edges.each do |edge|
    #   p "vertex"
    #   p edge.object_id
    #   p edge
    # end

    # @graph.vertices.each do |vertex|
    #   vertex.edges.each do |edge|
    #     p "graph"
    #     p edge.object_id
    #     p edge
    #   end
    # end
  end

  def test_vertices_dup
    vertices = @graph.vertices.dup

    rg_assert_equal @graph.vertices, vertices
    assert_nil   vertices.graph
    refute_same  @graph.vertices, vertices

    [vertices, @graph.vertices].transpose.each do |a, b|
      assert_instance_of Rgraphum::Vertex, a
      rg_assert_equal b, a
      refute_same b, a

      refute_empty a.edges
      assert_same  a.edges.vertex, a

      refute_same b.edges, a.edges

      a.edges.each do |edge|
        # assert           i = b.edges.index(edge)
        i = b.edges.index { |e| e.id == edge.id }

        refute_same b.edges[i], edge

        unless edge.target == a
          rg_assert_equal a, edge.source
        end

        unless edge.source == a
          rg_assert_equal a, edge.target
        end

        assert edge.source.object_id == a.object_id || edge.target.object_id == a.object_id
        unless edge.target.object_id == a.object_id
          assert_same a, edge.source
        end
        unless edge.source.object_id == a.object_id
          assert_same a, edge.target
        end

        unless b.edges[i].target.object_id == b.object_id
          assert_same b.edges[i].source, b
        end
        unless b.edges[i].source.object_id == b.object_id
          assert_same b.edges[i].target, b
        end
      end
    end
  end

  def test_graph_edges_dup
    edges_dup = @graph.edges.dup

    rg_assert_equal @graph.edges, edges_dup
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

    rg_assert_equal duped_graph.vertices, @graph.vertices
    refute_same  duped_graph.vertices, @graph.vertices

    rg_assert_equal duped_graph.edges, @graph.edges
    refute_same  duped_graph.edges, @graph.edges


    @graph.vertices.each_with_index do |vertex, vertex_index|
      duped_vertex = duped_graph.vertices[vertex_index]

      rg_assert_equal duped_vertex, vertex
      refute_same  duped_vertex, vertex

      vertex.edges.each_with_index do |edge,edge_index|
        duped_edge = duped_vertex.edges[edge_index]

        rg_assert_equal duped_edge, edge
        refute_same  duped_edge, edge

        rg_assert_equal duped_edge.source, edge.source
        refute_same  duped_edge.source, edge.source
        assert_same  duped_graph.vertices.where(id: duped_edge.source.id).first, duped_edge.source

        rg_assert_equal duped_edge.target, edge.target
        refute_same  duped_edge.target, edge.target
      end
    end

    @graph.edges.each_with_index do |edge,edge_index|
      duped_edge = duped_graph.edges[edge_index]

      rg_assert_equal duped_edge, edge
      refute_same  duped_edge, edge
    end
  end
end
