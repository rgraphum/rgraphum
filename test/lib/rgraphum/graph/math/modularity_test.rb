# -*- coding: utf-8 -*-

require 'test_helper'
require 'rgraphum'

class RgraphumMathModularityTest < MiniTest::Unit::TestCase
  def setup
    #  1 - 2
    #   \ /
    #    3
    #   / \
    #  4 - 5

    @graph = Rgraphum::Graph.new
    @graph.vertices = [
      { id: 1, label: "A", community_id: 1 },
      { id: 2, label: "B", community_id: 1 },
      { id: 3, label: "C" },
      { id: 4, label: "D" },
      { id: 5, label: "E" },
    ]
    @graph.edges = [
      { id: 0, source: 1, target: 2, weight: 1 },
      { id: 1, source: 1, target: 3, weight: 1 },
      { id: 2, source: 2, target: 3, weight: 1 },
      { id: 3, source: 3, target: 4, weight: 1 },
      { id: 4, source: 3, target: 5, weight: 1 },
      { id: 5, source: 4, target: 5, weight: 1 },
    ]
  end

  def test_modularity
    assert @graph.modularity
    assert_equal 1.0, @graph.modularity * 9.0

    community_id_a = @graph.vertices[0].community_id
    assert_equal @graph.vertices[0].community_id, community_id_a
    assert_equal @graph.vertices[1].community_id, community_id_a
    assert_equal @graph.vertices[2].community_id, community_id_a
    community_id_a = @graph.vertices[3].community_id
    assert_equal @graph.vertices[3].community_id, community_id_a
    assert_equal @graph.vertices[4].community_id, community_id_a

    @graph = Rgraphum::Graph.new
    @graph.vertices = [
      { id:  0, label:  "0" },
      { id:  1, label:  "1" },
      { id:  2, label:  "2" },
      { id:  3, label:  "3" },
      { id:  4, label:  "4" },
      { id:  5, label:  "5" },
      { id:  6, label:  "6" },
      { id:  7, label:  "7" },
      { id:  8, label:  "8" },
      { id:  9, label:  "9" },
      { id: 10, label: "10" },
      { id: 11, label: "11" },
      { id: 12, label: "12" },
      { id: 13, label: "13" },
      { id: 14, label: "14" },
      { id: 15, label: "15" },
    ]
    @graph.edges = [
      { id:  0, source:  0, target:  2, weight: 1 },
      { id:  1, source:  0, target:  3, weight: 1 },
      { id:  2, source:  0, target:  4, weight: 1 },
      { id:  3, source:  0, target:  5, weight: 1 },
      { id:  4, source:  1, target:  2, weight: 1 },
      { id:  5, source:  1, target:  4, weight: 1 },
      { id:  6, source:  1, target:  7, weight: 1 },
      { id:  7, source:  2, target:  4, weight: 1 },
      { id:  8, source:  2, target:  5, weight: 1 },
      { id:  9, source:  2, target:  6, weight: 1 },
      { id: 10, source:  3, target:  7, weight: 1 },
      { id: 11, source:  4, target: 10, weight: 1 },
      { id: 12, source:  5, target:  7, weight: 1 },
      { id: 13, source:  5, target: 11, weight: 1 },
      { id: 14, source:  6, target:  7, weight: 1 },
      { id: 15, source:  6, target: 11, weight: 1 },
      { id: 16, source:  8, target:  9, weight: 1 },
      { id: 17, source:  8, target: 10, weight: 1 },
      { id: 18, source:  8, target: 11, weight: 1 },
      { id: 19, source:  8, target: 14, weight: 1 },
      { id: 20, source:  8, target: 15, weight: 1 },
      { id: 21, source:  9, target: 12, weight: 1 },
      { id: 22, source:  9, target: 14, weight: 1 },
      { id: 23, source: 10, target: 11, weight: 1 },
      { id: 24, source: 10, target: 12, weight: 1 },
      { id: 25, source: 10, target: 13, weight: 1 },
      { id: 26, source: 10, target: 14, weight: 1 },
      { id: 27, source: 11, target: 13, weight: 1 },
    ]
    vertices = @graph.vertices
    edges = @graph.edges

    assert_equal 0.392, @graph.modularity.round(3)
    # @graph.modularity.round(3)

    community_id_a = @graph.vertices[0].community_id
    assert_equal 0, community_id_a
    assert_equal @graph.vertices[ 0].community_id, community_id_a
    assert_equal @graph.vertices[ 1].community_id, community_id_a
    assert_equal @graph.vertices[ 2].community_id, community_id_a
    assert_equal @graph.vertices[ 3].community_id, community_id_a
    assert_equal @graph.vertices[ 4].community_id, community_id_a
    assert_equal @graph.vertices[ 5].community_id, community_id_a
    assert_equal @graph.vertices[ 6].community_id, community_id_a
    assert_equal @graph.vertices[ 7].community_id, community_id_a

    community_id_b = @graph.vertices[8].community_id
    assert_equal 8, community_id_b
    assert_equal @graph.vertices[ 8].community_id, community_id_b
    assert_equal @graph.vertices[ 9].community_id, community_id_b
    assert_equal @graph.vertices[10].community_id, community_id_b
    assert_equal @graph.vertices[11].community_id, community_id_b
    assert_equal @graph.vertices[12].community_id, community_id_b
    assert_equal @graph.vertices[13].community_id, community_id_b
    assert_equal @graph.vertices[14].community_id, community_id_b

    # same graph befor after
    @graph.vertices.each_with_index do |vertex,i|
      assert_same vertex, vertices[i]
    end
    @graph.edges.each_with_index do |edge,i|
      assert_same edge.id, edges[i].id
      assert_same edge.weight, edges[i].weight

      assert_same edge.source, edges[i].source
      assert_same edge.target, edges[i].target
    end

    gexf = @graph.to_gephi
    file = File.open("tmp/modularity.gexf", "w")
    file.write(gexf)
  end

  def test_none_edges_modularity
    # nosw 3 is only vertex
    # vertex 1 - 2, 4 - 5 is one edge cluster

    @graph = Rgraphum::Graph.new
    @graph.vertices = [
      { id: 1, label: "A", community_id: 1 },
      { id: 2, label: "B", community_id: 1 },
      { id: 3, label: "C" },
      { id: 4, label: "D" },
      { id: 5, label: "E" },
    ]
    @graph.edges = [
      { id: 0, source: 1, target: 2, weight: 1 },
      { id: 5, source: 4, target: 5, weight: 1 },
    ]

    assert_equal 0.5,@graph.modularity
  end
end
