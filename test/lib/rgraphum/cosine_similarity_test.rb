# -*- coding: utf-8 -*-

require 'rgraphum'
require 'test_helper'

class CosineSimilarityTest < MiniTest::Unit::TestCase
  
  def test_similarity
    csm  = CosineSimilarityMatrix.new
    sim = csm.similarity( [[1,1],[1,-1],[-1,1],[-1,-1] ] )

    assert_equal [
           [ 1.0,  0.0,  0.0, -1.0],
           [ 0.0,  1.0, -1.0,  0.0],
           [ 0.0, -1.0,  1.0,  0.0],
           [-1.0,  0.0,  0.0,  1.0]], sim
  end
end
