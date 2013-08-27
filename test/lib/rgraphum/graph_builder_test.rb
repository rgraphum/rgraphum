# -*- coding: utf-8 -*-

require 'rgraphum'
require 'test_helper'

class RgraphumGraphBuilderTest < MiniTest::Test

  def test_build_from_from_adjacency_matrix
    labels =   ["hoge","huga","piyo","puyo"] 
    matrix = [ [  1.0 ,  0.7 ,  0.7 ,  nil ],
               [  nil ,  1.0 ,  nil ,  0.9 ],
               [  nil ,  0.8 ,  1.0 ,  0.3 ],
               [  nil ,  nil ,  nil ,  1.0 ] ]


    graph = Rgraphum::Graph.build_from_adjacency_matrix(matrix,labels)

    assert_equal    4,                     graph.edges.size

    rg_assert_equal graph.edges[0].source, graph.vertices[0]
    rg_assert_equal graph.edges[0].target, graph.vertices[1]
    rg_assert_equal graph.edges[0].weight, 0.7
    
    rg_assert_equal graph.edges[1].source, graph.vertices[0]
    rg_assert_equal graph.edges[1].target, graph.vertices[2]
    rg_assert_equal graph.edges[1].weight, 0.7

    rg_assert_equal graph.edges[2].source, graph.vertices[1]
    rg_assert_equal graph.edges[2].target, graph.vertices[3]
    rg_assert_equal graph.edges[2].weight, 0.9

    rg_assert_equal graph.edges[3].source, graph.vertices[2]
    rg_assert_equal graph.edges[3].target, graph.vertices[1]
    rg_assert_equal graph.edges[3].weight, 0.8


    graph = Rgraphum::Graph.build_from_adjacency_matrix(matrix,labels,{:loop=>true,limit:0.8})

    rg_assert_equal graph.edges[0].source, graph.vertices[0]
    rg_assert_equal graph.edges[0].target, graph.vertices[0]
    rg_assert_equal graph.edges[0].weight, 1.0

    rg_assert_equal graph.edges[1].source, graph.vertices[1]
    rg_assert_equal graph.edges[1].target, graph.vertices[1]
    rg_assert_equal graph.edges[1].weight, 1.0

    rg_assert_equal graph.edges[2].source, graph.vertices[1]
    rg_assert_equal graph.edges[2].target, graph.vertices[3]
    rg_assert_equal graph.edges[2].weight, 0.9
    
    rg_assert_equal graph.edges[3].source, graph.vertices[2]
    rg_assert_equal graph.edges[3].target, graph.vertices[1]
    rg_assert_equal graph.edges[3].weight, 0.8

    rg_assert_equal graph.edges[4].source, graph.vertices[2]
    rg_assert_equal graph.edges[4].target, graph.vertices[2]
    rg_assert_equal graph.edges[4].weight, 1.0

    rg_assert_equal graph.edges[5].source, graph.vertices[3]
    rg_assert_equal graph.edges[5].target, graph.vertices[3]
    rg_assert_equal graph.edges[5].weight, 1.0
        
  end
end
