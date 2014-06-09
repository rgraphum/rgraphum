# -*- coding: utf-8 -*-

require 'test_helper'
require 'rgraphum'

class AdjacencyMatrixTest < MiniTest::Unit::TestCase
  def setup
    #  1 - 2
    #   \ /
    #    3
    #   / \
    #  4 - 5

    @graph = Rgraphum::Graph.new
    @graph.vertices = [
      { id: 1, label: "A" },
      { id: 2, label: "B" },
      { id: 3, label: "C" },
      { id: 4, label: "D" },
      { id: 5, label: "E" },
    ]
    @graph.edges = [
      { id: 0, source: 1, target: 2, weight: 1 },
      { id: 1, source: 1, target: 3, weight: 2 },
      { id: 2, source: 2, target: 3, weight: 1 },
      { id: 3, source: 3, target: 4, weight: 2 },
      { id: 4, source: 3, target: 5, weight: 1 },
      { id: 5, source: 4, target: 5, weight: 1 },
    ]
  end

  def test_adjacency_matrix

    matrix = @graph.adjacency_matrix
    matrix_index = @graph.adjacency_matrix_index

    expected = [
      #   1    2   3     4    5
      [ nil, nil, nil, nil, nil], # 1
      [   1, nil, nil, nil, nil], # 2
      [   2,   1, nil, nil, nil], # 3
      [ nil, nil,   2, nil, nil], # 4
      [ nil, nil,   1,   1, nil], # 5
    ]

    assert_equal expected, matrix

  end
end
