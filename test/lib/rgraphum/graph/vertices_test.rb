# -*- coding: utf-8 -*-

require 'rgraphum'
require 'test_helper'

class RgraphumVerticesTest < MiniTest::Unit::TestCase
  def setup
    @graph = Rgraphum::Graph.new
    @graph.vertices << { id: 1, label: "hoge" }
    @graph.vertices << { id: 2, label: "huga" }

    @vertex0, @vertex1 = @graph.vertices
  end

  def test_vertices
    assert_instance_of Rgraphum::Vertex,   @vertex0
    assert_empty @vertex0.edges
    assert_instance_of Rgraphum::Edges,  @vertex0.edges

    @vertex0.edges << { source: @vertex0, target: @vertex1 }

    assert_equal 1,  @vertex0.edges.size
    assert_equal 1, @vertex0.edges[0].id
    assert_equal @vertex0.rgraphum_id, @vertex0.edges[0].source.rgraphum_id
    assert_equal @vertex1.rgraphum_id, @vertex0.edges[0].target.rgraphum_id
    assert_equal @vertex0.rgraphum_id, @vertex0.edges[0].source.rgraphum_id
    assert_equal @vertex1.rgraphum_id, @vertex0.edges[0].target.rgraphum_id

    assert_equal 1, @vertex1.edges.size
    assert_equal 1, @vertex1.edges[0].id
    assert_equal @vertex0.rgraphum_id, @vertex1.edges[0].source.rgraphum_id
    assert_equal @vertex1.rgraphum_id, @vertex1.edges[0].target.rgraphum_id

    assert_equal 1, @graph.edges.size
    assert_equal 1, @graph.edges[0].id
    assert_equal @vertex0.rgraphum_id, @graph.edges[0].source.rgraphum_id
    assert_equal @vertex1.rgraphum_id, @graph.edges[0].target.rgraphum_id
  end

  def test_vertices_dump_and_load
    vertex1 = Rgraphum::Vertex(id: 1, label: "vertex 1")
    vertex2 = Rgraphum::Vertex(id: 2, label: "vertex 2")
    vertices = [vertex1, vertex2, vertex1]

    data = Marshal.dump(vertices)
    vertices_dash = Marshal.load(data)

    assert_equal vertices, vertices_dash
    refute_equal vertices_dash[0], vertices_dash[1]
    assert_same  vertices_dash[0], vertices_dash[2]
  end

  def test_finders_with_where

    10.times do |i|
      @graph.vertices << { label: "aaa" }
    end
    @graph.vertices << { label: "foo" }
    @graph.vertices << { label: "bar" }

    assert_equal 2,  @graph.vertices.where(label: "huga").first.id
    assert_equal 3,  @graph.vertices.where(label: "aaa").first.id
    assert_equal 12, @graph.vertices.where(label: "aaa").last.id
    assert_equal 10, @graph.vertices.where(label: "aaa").all.size
  end

  def test_delete
    @vertex2 = @graph.vertices.build(label: "v 2")
    @vertex3 = @graph.vertices.build(label: "v 3")
    @graph.edges << { source: @vertex0, target: @vertex1 }
    @graph.edges << { source: @vertex1, target: @vertex2 }
    @graph.edges << { source: @vertex2, target: @vertex3 }
    @graph.edges << { source: @vertex3, target: @vertex0 }

    # v0 -> v1 -> v2 -> v3
    #  ^                 |
    #  +-----------------+
    assert_equal 4, @graph.vertices.size
    assert_equal 4, @graph.edges.size

    @graph.vertices.delete @vertex2

    # v0 -> v1          v3
    #  ^                 |
    #  +-----------------+
    assert_equal 3, @graph.vertices.size
    assert_equal 2, @graph.edges.size
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
    graph.vertices do |vertex|
      assert_equal 2, vertex.edges.size
    end

    graph.vertices.delete_if { |vertex|
      (vertex.label.delete('v').to_i % 3) == 0
    }

    #       v1 -> v2          v4 -> v5          v7 -> v8
    assert_equal  6, graph.vertices.size
    assert_equal  3, graph.edges.size

    assert_equal  "v1", graph.vertices[0].label
    assert_equal  "v2", graph.vertices[1].label
    assert_equal  "v4", graph.vertices[2].label
    assert_equal  "v5", graph.vertices[3].label
    assert_equal  "v7", graph.vertices[4].label
    assert_equal  "v8", graph.vertices[5].label

    graph.vertices do |vertex|
      assert_equal 1, vertex.edges.size
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
    assert_equal 10, graph.vertices.size

    rejected_vertices = graph.vertices.reject { |vertex|
      (vertex.label.delete('v').to_i % 3) == 0
    }

    assert_equal 10, graph.vertices.size, "Should not change size"

    #       v1 -> v2          v4 -> v5          v7 -> v8
    assert_equal  6, rejected_vertices.size
  end

  def test_plural_set
    expected_vertices = [
      { label: "A" },
      { label: "B" },
      { label: "C" },
    ]

    graph = Rgraphum::Graph.new
    graph.vertices = expected_vertices

    expected_vertices.each_with_index do |expected_vertex, i|
      assert_equal expected_vertex[:label], graph.vertices[i].label
    end
  end
end
