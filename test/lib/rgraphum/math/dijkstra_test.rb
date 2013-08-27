# -*- coding: utf-8 -*-

require 'rgraphum'
require 'test_helper'

class RgraphumMathDijkstraTest < MiniTest::Test
  def setup
    @graph = Rgraphum::Graph.new
    # @graph.vertices = [
    #   { label: "A" },
    #   { label: "B" },
    #   { label: "C" },
    #   { label: "D" },
    #   { label: "G" },
    # ]
    @a = @graph.vertices.build(label: "A")
    @b = @graph.vertices.build(label: "B")
    @c = @graph.vertices.build(label: "C")
    @d = @graph.vertices.build(label: "D")
    @g = @graph.vertices.build(label: "G")
  end

  # A --(5)-- B --(1)-- G
  # | ＼      |       ／
  #(1)  (4)  (2)  (4)
  # |      ＼ | ／
  # C --(5)-- D
  #
  def test_adjacency_matrix_1
    @graph.edges.build(source: @a, target: @b, weight: 5) # A->B
    @graph.edges.build(source: @a, target: @c, weight: 1) # A->C
    @graph.edges.build(source: @a, target: @d, weight: 4) # A->D
    @graph.edges.build(source: @b, target: @d, weight: 2) # B->D
    @graph.edges.build(source: @c, target: @d, weight: 5) # C->D
    @graph.edges.build(source: @b, target: @g, weight: 1) # B->G
    @graph.edges.build(source: @d, target: @g, weight: 4) # D->G

    a_matrix = @graph.adjacency_matrix

    expected = [
      #  A    B    C    D    G
      [nil,   5,   1,   4, nil], # A
      [  5, nil, nil,   2,   1], # B
      [  1, nil, nil,   5, nil], # C
      [  4,   2,   5, nil,   4], # D
      [nil,   1, nil,   4, nil], # G
    ]

    assert_equal expected, a_matrix
  end

  # A --(1)-- B --(4)-- G
  # | ＼      |       ／
  #(2)  (4)  (2)  (1)
  # |      ＼ | ／
  # C --(3)-- D
  #
  # A -> G : A -> B -> D -> G
  def test_dijkstra_1
    @graph.edges.build(source: @a, target: @b, weight: 1) # A->B
    @graph.edges.build(source: @a, target: @c, weight: 2) # A->C
    @graph.edges.build(source: @a, target: @d, weight: 4) # A->D
    @graph.edges.build(source: @b, target: @d, weight: 2) # B->D
    @graph.edges.build(source: @c, target: @d, weight: 3) # C->D
    @graph.edges.build(source: @b, target: @g, weight: 4) # B->G
    @graph.edges.build(source: @d, target: @g, weight: 1) # D->G

    vertices = @graph.dijkstra(@a, @g)
    # p vertices.map(&:label)

    assert_equal 4, vertices.size
    assert_equal vertices[0], @a
    assert_equal vertices[1], @b
    assert_equal vertices[2], @d
    assert_equal vertices[3], @g
  end

  # A --(5)-- B --(1)-- G
  # | ＼      |       ／
  #(1)  (4)  (2)  (4)
  # |      ＼ | ／
  # C --(5)-- D
  #
  # A -> G : A -> B -> G
  def test_dijkstra_2
    @graph.edges.build(source: @a, target: @b, weight: 5) # A->B
    @graph.edges.build(source: @a, target: @c, weight: 1) # A->C
    @graph.edges.build(source: @a, target: @d, weight: 4) # A->D
    @graph.edges.build(source: @b, target: @d, weight: 2) # B->D
    @graph.edges.build(source: @c, target: @d, weight: 5) # C->D
    @graph.edges.build(source: @b, target: @g, weight: 1) # B->G
    @graph.edges.build(source: @d, target: @g, weight: 4) # D->G

    vertices = @graph.dijkstra(@a, @g)
    # p vertices.map(&:label)

    assert_equal 3, vertices.size
    assert_equal vertices[0], @a
    assert_equal vertices[1], @b
    assert_equal vertices[2], @g
  end

  # A --(5)-- B --(1)-- G
  # | ＼      |       ／
  #(1)  (4)  (2)  (4)
  # |      ＼ | ／
  # C --(5)-- D
  #
  # A -> B : A -> B
  def test_dijkstra_3
    @graph.edges.build(source: @a, target: @b, weight: 5) # A->B
    @graph.edges.build(source: @a, target: @c, weight: 1) # A->C
    @graph.edges.build(source: @a, target: @d, weight: 4) # A->D
    @graph.edges.build(source: @b, target: @d, weight: 2) # B->D
    @graph.edges.build(source: @c, target: @d, weight: 5) # C->D
    @graph.edges.build(source: @b, target: @g, weight: 1) # B->G
    @graph.edges.build(source: @d, target: @g, weight: 4) # D->G

    vertices = @graph.dijkstra(@a, @b)
    assert_equal 2, vertices.size
    assert_equal vertices[0], @a
    assert_equal vertices[1], @b
  end

  # A --(5)-- B --(1)-- G
  # | ＼      |       ／
  #(1)  (4)  (2)  (4)
  # |      ＼ | ／
  # C --(5)-- D
  #
  # A -> C : A -> C
  def test_dijkstra_4
    @graph.edges.build(source: @a, target: @b, weight: 5) # A->B
    @graph.edges.build(source: @a, target: @c, weight: 1) # A->C
    @graph.edges.build(source: @a, target: @d, weight: 4) # A->D
    @graph.edges.build(source: @b, target: @d, weight: 2) # B->D
    @graph.edges.build(source: @c, target: @d, weight: 5) # C->D
    @graph.edges.build(source: @b, target: @g, weight: 1) # B->G
    @graph.edges.build(source: @d, target: @g, weight: 4) # D->G

    vertices = @graph.dijkstra(@a, @c)
    assert_equal 2, vertices.size
    assert_equal vertices[0], @a
    assert_equal vertices[1], @c
  end
end
