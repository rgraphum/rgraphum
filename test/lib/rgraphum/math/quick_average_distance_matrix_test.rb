# -*- coding: utf-8 -*-

require 'rgraphum'
require 'test_helper'

class RgraphumMathQuickAverageDistanceMatrixTest < MiniTest::Test
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
  def test_average_distance_1
    @graph.edges.build(source: @a, target: @b, weight: 5) # A->B
    @graph.edges.build(source: @a, target: @c, weight: 1) # A->C
    @graph.edges.build(source: @a, target: @d, weight: 4) # A->D
    @graph.edges.build(source: @b, target: @d, weight: 2) # B->D
    @graph.edges.build(source: @c, target: @d, weight: 5) # C->D
    @graph.edges.build(source: @b, target: @g, weight: 1) # B->G
    @graph.edges.build(source: @d, target: @g, weight: 4) # D->G

    average_distance = @graph.quick_average_distance

    n = @graph.vertices.size
    minimum_distance_matrix = [
      #  A    B    C    D    G
      [  0,   5,   1,   4,   6 ], # A
      [  5,   0,   6,   2,   1 ], # B
      [  1,   6,   0,   5,   7 ], # C
      [  4,   2,   5,   0,   3 ], # D
      [  6,   1,   7,   3,   0 ], # G
    ]
    expected = Rational(minimum_distance_matrix.flatten.inject(&:+), n * (n - 1))

    assert_equal expected, average_distance
  end

  # A --(1)-- B --(4)-- G
  # | ＼      |       ／
  #(2)  (4)  (2)  (1)
  # |      ＼ | ／
  # C --(3)-- D
  #
  def test_average_distance_2
    @graph.edges.build(source: @a, target: @b, weight: 1) # A->B
    @graph.edges.build(source: @a, target: @c, weight: 2) # A->C
    @graph.edges.build(source: @a, target: @d, weight: 4) # A->D
    @graph.edges.build(source: @b, target: @d, weight: 2) # B->D
    @graph.edges.build(source: @c, target: @d, weight: 3) # C->D
    @graph.edges.build(source: @b, target: @g, weight: 4) # B->G
    @graph.edges.build(source: @d, target: @g, weight: 1) # D->G

    average_distance = @graph.quick_average_distance

    n = @graph.vertices.size
    minimum_distance_matrix = [
      #  A    B    C    D    G
      [  0,   1,   2,   3,   4 ], # A
      [  1,   0,   3,   2,   3 ], # B
      [  2,   3,   0,   3,   4 ], # C
      [  3,   2,   3,   0,   1 ], # D
      [  4,   3,   4,   1,   0 ], # G
    ]
    expected = Rational(minimum_distance_matrix.flatten.inject(&:+), n * (n - 1))

    assert_equal expected, average_distance
  end
end
