# -*- coding: utf-8 -*-

require 'rgraphum'
require 'test_helper'

class RgraphumMathClusteringCoefficientTest < MiniTest::Unit::TestCase
  def setup
  end

  def test_local_clustering_coefficient_with_complete_graph
    # B---C
    # |\ /|
    # | A |
    # \ | /
    #   D
    graph = Rgraphum::Graph.new
    a = graph.vertices.build(label: "A")
    b = graph.vertices.build(label: "B")
    c = graph.vertices.build(label: "C")
    d = graph.vertices.build(label: "D")

    graph.edges.build(source: a, target: b)
    graph.edges.build(source: a, target: c)
    graph.edges.build(source: a, target: d)

    graph.edges.build(source: b, target: c)
    graph.edges.build(source: c, target: d)
    graph.edges.build(source: d, target: b)

    # B - C  B\    /C
    #  \ /   | A  A |
    #   A    D/    \D
    assert_equal "3/3".to_r, a.clustering_coefficient
    # B - C  B\        B - C
    #  \ /   | A        \ /
    #   A    D/          D
    assert_equal "3/3".to_r, b.clustering_coefficient
    # B - C        /C  B - C
    #  \ /        A |   \ /
    #   A          \D    D
    assert_equal "3/3".to_r, c.clustering_coefficient
    #        B\    /C  B - C
    #        | A  A |   \ /
    #        D/    \D    D
    assert_equal "3/3".to_r, d.clustering_coefficient
  end

  def test_local_clustering_coefficient_with_non_complete_graph_1
    # B---C
    #  \ /
    #   A
    #   |
    #   D
    graph = Rgraphum::Graph.new
    a = graph.vertices.build(label: "A")
    b = graph.vertices.build(label: "B")
    c = graph.vertices.build(label: "C")
    d = graph.vertices.build(label: "D")

    graph.edges.build(source: a, target: b)
    graph.edges.build(source: a, target: c)
    graph.edges.build(source: a, target: d)

    graph.edges.build(source: b, target: c)

    # B - C  B\    /C
    #  \ /     A  A
    #   A    D/    \D
    assert_equal "1/3".to_r, a.clustering_coefficient
    # B - C
    #  \ /
    #   A
    assert_equal "1/1".to_r, b.clustering_coefficient
    # B - C
    #  \ /
    #   A
    assert_equal "1/1".to_r, c.clustering_coefficient
    #
    #
    #
    assert_equal "0".to_r, d.clustering_coefficient
  end

  def test_local_clustering_coefficient_with_non_complete_graph_2
    # B---C
    #  \ /|
    #   A |
    #   |/
    #   D
    graph = Rgraphum::Graph.new
    a = graph.vertices.build(label: "A")
    b = graph.vertices.build(label: "B")
    c = graph.vertices.build(label: "C")
    d = graph.vertices.build(label: "D")

    graph.edges.build(source: a, target: b)
    graph.edges.build(source: a, target: c)
    graph.edges.build(source: a, target: d)

    graph.edges.build(source: b, target: c)
    graph.edges.build(source: c, target: d)

    # B - C  B\    /C
    #  \ /     A  A |
    #   A    D/    \D
    assert_equal "2/3".to_r, a.clustering_coefficient
    # B - C
    #  \ /
    #   A
    assert_equal "1/1".to_r, b.clustering_coefficient
    # B - C        /C  B - C
    #    /        A |   \ /
    #   A          \D    D
    assert_equal "2/3".to_r, c.clustering_coefficient
    #              /C
    #             A |
    #              \D
    assert_equal "1/1".to_r, d.clustering_coefficient
  end

  def test_global_clustering_coefficient_with_complete_graph
    # B---C
    # |\ /|
    # | A |
    # \ | /
    #   D
    graph = Rgraphum::Graph.new
    a = graph.vertices.build(label: "A")
    b = graph.vertices.build(label: "B")
    c = graph.vertices.build(label: "C")
    d = graph.vertices.build(label: "D")

    graph.edges.build(source: a, target: b)
    graph.edges.build(source: a, target: c)
    graph.edges.build(source: a, target: d)

    graph.edges.build(source: b, target: c)
    graph.edges.build(source: c, target: d)
    graph.edges.build(source: d, target: b)

    # assert_equal "3/3".to_r, a.clustering_coefficient
    # assert_equal "3/3".to_r, b.clustering_coefficient
    # assert_equal "3/3".to_r, c.clustering_coefficient
    # assert_equal "3/3".to_r, d.clustering_coefficient

    # N: 4
    #         N
    # 1/N * Σ Ci
    #        i=0
    #
    # 1/4 * (3/3 + 3/3 + 3/3 + 3/3) = 1
    assert_equal "1".to_r, graph.clustering_coefficient
  end

  def test_global_clustering_coefficient_with_non_complete_graph_1
    # B---C
    #  \ /
    #   A
    #   |
    #   D
    graph = Rgraphum::Graph.new
    a = graph.vertices.build(label: "A")
    b = graph.vertices.build(label: "B")
    c = graph.vertices.build(label: "C")
    d = graph.vertices.build(label: "D")

    graph.edges.build(source: a, target: b)
    graph.edges.build(source: a, target: c)
    graph.edges.build(source: a, target: d)

    graph.edges.build(source: b, target: c)

    # assert_equal "1/3".to_r, a.clustering_coefficient
    # assert_equal "1/1".to_r, b.clustering_coefficient
    # assert_equal "1/1".to_r, c.clustering_coefficient
    # assert_equal "0".to_r, d.clustering_coefficient

    # N: 4
    #         N
    # 1/N * Σ Ci
    #        i=0
    #
    # 1/4 * (1/3 + 1/1 + 1/1 + 0) = 1/4 * (7/3) = 7/12
    assert_equal "7/12".to_r, graph.clustering_coefficient
  end

  def test_global_clustering_coefficient_with_non_complete_graph_2
    # B---C
    #  \ /|
    #   A |
    #   |/
    #   D
    graph = Rgraphum::Graph.new
    a = graph.vertices.build(label: "A")
    b = graph.vertices.build(label: "B")
    c = graph.vertices.build(label: "C")
    d = graph.vertices.build(label: "D")

    graph.edges.build(source: a, target: b)
    graph.edges.build(source: a, target: c)
    graph.edges.build(source: a, target: d)

    graph.edges.build(source: b, target: c)
    graph.edges.build(source: c, target: d)

    # assert_equal "2/3".to_r, a.clustering_coefficient
    # assert_equal "1/1".to_r, b.clustering_coefficient
    # assert_equal "2/3".to_r, c.clustering_coefficient
    # assert_equal "1/1".to_r, d.clustering_coefficient

    # N: 4
    #         N
    # 1/N * Σ Ci
    #        i=0
    #
    # 1/4 * (2/3 + 1/1 + 2/3 + 1/1) = 1/4 * (4/3 + 2/1) = 1/4 * (10/3) = 10/12 = 5/6
    assert_equal "5/6".to_r, graph.clustering_coefficient
  end
end
