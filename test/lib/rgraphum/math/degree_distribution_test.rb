# -*- coding: utf-8 -*-

require 'rgraphum'
require 'test_helper'

class  DegreeDistributionTest < MiniTest::Test


  def setup
    #  a - b
    #   \ /
    #    c
    #   / \
    #  d - e
    @graph = Rgraphum::Graph.new

    @a = @graph.vertices.build(label: "a")
    @b = @graph.vertices.build(label: "b")
    @c = @graph.vertices.build(label: "c")
    @d = @graph.vertices.build(label: "d")
    @e = @graph.vertices.build(label: "e")

    @a_b_e = @graph.edges.build(source: @a, target: @b)
    @a_c_e = @graph.edges.build(source: @a, target: @c)
    @b_c_e = @graph.edges.build(source: @b, target: @c)
    @c_b_e = @graph.edges.build(source: @c, target: @d)
    @c_e_e = @graph.edges.build(source: @c, target: @e)
    @d_e_e = @graph.edges.build(source: @d, target: @e)
    
  end

  def test_degree_distribution
    assert_equal ( {2=>0.8, 4=>0.2} ) , @graph.degree_distribution
  end

  def test_degree_distribution_exponent
    assert_equal -2.0, @graph.degree_distribution_exponent
  end

end
