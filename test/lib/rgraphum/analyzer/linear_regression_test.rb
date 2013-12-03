# coding: utf-8

require 'test_helper'
require 'rgraphum'

class LinearRegressionTest < MiniTest::Unit::TestCase
  def test_analyze
    lr = Rgraphum::Analyzer::LinearRegression.new

    # 1 degree
    assert_equal ([2,3]), lr.analyze([1,2,3],[5,7,9])
    assert_equal ([3,4]), lr.analyze([1,2,3],[7,10,13])
    assert_equal ([4,5]), lr.analyze([1,2,3],[9,13,17])

    # 2 degree
#    assert_equal ([2,3,4]),lr.analyze([1,2,3],[9,18,31],2) 
#    assert_equal ([3,4,5]),lr.analyze([1,2,3],[12,25,44],2) 
#    assert_equal ([4,5,6]),lr.analyze([1,2,3],[15,32,57],2) 
  end
end
