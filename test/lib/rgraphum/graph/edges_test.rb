# -*- coding: utf-8 -*-

require 'rgraphum'
require 'test_helper'

class RgraphumEdgesTest < MiniTest::Unit::TestCase
  def setup
    @graph = Rgraphum::Graph.new
    @graph.vertices << { id: 1, label: "hoge" }
    @graph.vertices << { id: 2, label: "huga" }

    @vertex0, @vertex1 = @graph.vertices
    @vertex0.edges << { source: @vertex0, target: @vertex1 }

    @edge0 = @graph.edges[0]
  end

  def test_edges
    assert_instance_of Rgraphum::Vertex, @vertex0
    assert_instance_of Rgraphum::Edges,  @vertex0.edges
    assert_instance_of Rgraphum::Edges,  @vertex0.in_edges
    assert_instance_of Rgraphum::Edges,  @vertex0.out_edges

    assert_equal 1, @vertex0.edges.size
    assert_equal 1, @vertex0.out_edges.size
    assert_equal 0, @vertex0.in_edges.size

    assert_equal 1, @vertex0.edges[0].id
    assert_equal @vertex0.object_id, @vertex0.edges[0].source.object_id
    assert_equal @vertex1.object_id, @vertex0.edges[0].target.object_id

    assert_equal 1, @vertex1.edges.size
    assert_equal 0, @vertex1.out_edges.size
    assert_equal 1, @vertex1.in_edges.size

    assert_equal 1, @vertex1.edges[0].id
    assert_equal @vertex0.object_id, @vertex1.edges[0].source.object_id
    assert_equal @vertex1.object_id, @vertex1.edges[0].target.object_id

    assert_equal 1, @graph.edges.size
    assert_equal 1, @graph.edges[0].id
    assert_equal @vertex0.object_id, @graph.edges[0].source.object_id
    assert_equal @vertex1.object_id, @graph.edges[0].target.object_id
  end

  def test_edges_dump_and_load
    vertex1 = Rgraphum::Vertex.new(id: 1, label: "vertex 1")
    vertex2 = Rgraphum::Vertex.new(id: 2, label: "vertex 2")
    vertex3 = Rgraphum::Vertex.new(id: 3, label: "vertex 3")
    edge1 = Rgraphum::Edge.new(source: vertex1, target: vertex2)
    edge2 = Rgraphum::Edge.new(source: vertex2, target: vertex3)
    edges = [edge1, edge2, edge1]

    data = Marshal.dump(edges)
    edges_dash = Marshal.load(data)

    assert_equal edges, edges_dash
    refute_equal edges_dash[0].object_id, edges_dash[1].object_id
    assert_equal edges_dash[0].object_id, edges_dash[2].object_id
  end

  def test_delete
    @graph.edges << { source: @vertex1, target: @vertex0 }
    @edge1 = @graph.edges[-1]
    # v0 -> v1
    #    <-
    assert_equal 2, @graph.vertices.size
    assert_equal 2, @graph.edges.size

    @graph.edges.delete @edge0

    # v0    v1
    #    <-
    assert_equal 2, @graph.vertices.size
    assert_equal 1, @graph.edges.size
    assert_equal 1, @vertex0.edges.size
    assert_equal 1, @vertex1.edges.size
    assert_equal @edge1.object_id,@vertex0.edges[0].object_id
    assert_equal @edge1.object_id,@vertex1.edges[0].object_id
    assert_equal @edge1.source.object_id, @vertex1.object_id
    assert_equal @edge1.target.object_id, @vertex0.object_id
  end

  # delete_if calls delete
  # delete_if == reject!
  def test_delete_if
    graph = Rgraphum::Graph.new
    (0..9).each do |i|
      graph.vertices << { label: "v#{i}" }
    end
    (0..9).each do |i|
      graph.edges << {
        source: graph.vertices[i],
        target: graph.vertices[(i+1) % 10],
        weight: i,
      }
    end

    # v0 -> v1 -> v2 -> v3 -> v4 -> v5 -> v6 -> v7 -> v8 -> v9
    #  ^                                                     |
    #  +-----------------------------------------------------+
    assert_equal 10, graph.vertices.size
    assert_equal 10, graph.edges.size
    graph.vertices.each do |vertex|
      assert_equal 2, vertex.edges.size
      assert_equal 1, vertex.in_edges.size
      assert_equal 1, vertex.out_edges.size
    end

    graph.edges.delete_if { |edge| edge.weight.to_i.odd? }
    # graph.edges.reject! { |edge| edge.weight.odd? }

    # v0 -> v1    v2 -> v3    v4 -> v5    v6 -> v7    v8 -> v9
    assert_equal 10, graph.vertices.size
    assert_equal  5, graph.edges.size, "edges.size was 10 but deleted 5 edges"

    assert_equal  0, graph.edges[0].weight
    assert_equal  2, graph.edges[1].weight
    assert_equal  4, graph.edges[2].weight
    assert_equal  6, graph.edges[3].weight
    assert_equal  8, graph.edges[4].weight

    graph.vertices.each do |vertex|
      assert_equal 1, vertex.edges.size
      assert_equal 1, ( vertex.in_edges.size + vertex.out_edges.size )
    end
  end

  def test_reject
    graph = Rgraphum::Graph.new
    (0..9).each do |i|
      graph.vertices << { label: "v#{i}" }
    end
    (0..9).each do |i|
      graph.edges << {
        source: graph.vertices[i],
        target: graph.vertices[(i+1) % 10],
        weight: i,
      }
    end

    # v0 -> v1 -> v2 -> v3 -> v4 -> v5 -> v6 -> v7 -> v8 -> v9
    #  ^                                                     |
    #  +-----------------------------------------------------+
    assert_equal 10, graph.edges.size

    rejected_edges = graph.edges.reject { |edge| edge.weight.to_i.odd? }

    assert_equal 10, graph.vertices.size, "Should not change size"
    assert_equal 10, graph.edges.size,    "Should not change size"

    # v0 -> v1    v2 -> v3    v4 -> v5    v6 -> v7    v8 -> v9
    assert_equal  5, rejected_edges.size, "edges.size was 10 but deleted 5 edges"
  end

  def test_build_with_invalid_source
    v1 = @graph.vertices.build(label: "1")
    v2 = @graph.vertices.build(label: "2")

    assert_raises(ArgumentError) do
      @graph.edges.build(target: v2, label: "label")
    end

    assert_raises(ArgumentError) do
      @graph.edges.build(source: nil, target: v2, label: "label")
    end
  end

  def test_build_with_invalid_target
    v1 = @graph.vertices.build(label: "1")
    v2 = @graph.vertices.build(label: "2")

    assert_raises(ArgumentError) do
      @graph.edges.build(source: v1, label: "label")
    end

    assert_raises(ArgumentError) do
      @graph.edges.build(source: v1, target: nil, label: "label")
    end
  end

end
