# -*- coding: utf-8 -*-

require 'rgraphum'
require 'test_helper'

class TfIdfTest  < MiniTest::Test

  def test_tf_idf_c
    labels  = [  "A", "B", "C", "D", "E" ]
    matrix  = [ [2.0, 1.0, 1.0, 0.0, 0.0],
                [0.0, 2.0, 1.0, 1.0, 0.0],
                [1.0, 1.0, 1.0, 0.0, 0.0],
                [0.0, 0.0, 0.0, 1.0, 1.0]]

    
    tf_idf_object = TfIdf.new
    tf_idf = tf_idf_object.tf_idf( matrix )

    tf_idf_ans_lib = [ [0.34657359027997264, 0.07192051811294521, 0.07192051811294521, 0.0,                 0.0],
                       [0.0,                 0.14384103622589042, 0.07192051811294521, 0.17328679513998632, 0.0],
                       [0.23104906018664842, 0.09589402415059362, 0.09589402415059362, 0.0,                 0.0],
                       [0.0,                 0.0,                 0.0,                 0.34657359027997264, 0.6931471805599453] ]

    tf_idf_ans_lib.flatten.each_with_index do |ans_tmp,i|
      assert_equal ans_tmp.round(5), tf_idf.flatten[i].round(5)
    end

  end

end
