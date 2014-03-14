# -*- coding: utf-8 -*-

require 'rgraphum'
require 'test_helper'

class VertexValueMatrixTest < MiniTest::Unit::TestCase

  def test_build_vertex_value_matrix
    #        x, y, z 
    # hoge [ 1, 1, 0 ]
    # huga [ 1, 0, 1 ]
    # piyo [ 0, 1, 1 ]
    # puyo [ 1, 0, 0 ]
    #

    data = [ ["hoge","x"],
             ["hoge","y"],
             ["huga","x"],
             ["huga","z"],
             ["puyo","x"],
             ["piyo","y"],
             ["piyo","z"]]

    counts_data = [ ["hoge","x",1.0],
                    ["hoge","y",1.0],
                    ["huga","x",1.0],
                    ["huga","z",1.0],
                    ["puyo","x",1.0],
                    ["piyo","y",1.0],
                    ["piyo","z",1.0]]

    vertex_labels = ["hoge","huga","puyo","piyo"]

    assert_equal VertexValueMatrix.add_count_values(data),counts_data
    assert_equal VertexValueMatrix.pickup_vertex_labels(data),vertex_labels


    vertex_labels_with_hura = ["hoge","huga","puyo","hura","piyo"]
    matrix_with_zero = [ [ 1, 1, 0, 0 ],
                         [ 1, 0, 0, 1 ],
                         [ 1, 0, 0, 0 ],
                         [ 0, 0, 0, 0 ],
                         [ 0, 1, 0, 1 ] ]

    matrix = [ [ 1, 1, 0 ],
               [ 1, 0, 1 ],
               [ 1, 0, 0 ],
               [ 0, 1, 1 ] ]

    vertex_labels_remove_puyo = ["hoge","huga","piyo"]
    matrix_remove_sum_one = [ [ 1, 1, 0 ],
                              [ 1, 0, 1 ],
                              [ 0, 1, 1 ] ]

    assert_equal VertexValueMatrix.sum_limit_filter( matrix_with_zero,vertex_labels_with_hura.dup,{vertex_limit:1}),([ matrix_remove_sum_one, vertex_labels_remove_puyo])
    assert_equal VertexValueMatrix.zero_filter(matrix_with_zero,vertex_labels_with_hura),                       ([ matrix, vertex_labels])

  end
end
