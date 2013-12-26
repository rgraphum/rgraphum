# -*- coding: utf-8 -*-

require 'rgraphum'
require 'test_helper'

class RgraphumPathTest < MiniTest::Unit::TestCase
  def setup
    @graph = Rgraphum::Graph.new
    @v1 = @graph.vertices.build(label: "v1")
    @v2 = @graph.vertices.build(label: "v2")
    @v3 = @graph.vertices.build(label: "v3")
    @v4 = @graph.vertices.build(label: "v4")
    @v5 = @graph.vertices.build(label: "v5")
    @v6 = @graph.vertices.build(label: "v6")

    @e1 = @graph.edges.build(source: @v1, target: @v2, weight: 1)
    @e2 = @graph.edges.build(source: @v2, target: @v3, weight: 2)
    @e3 = @graph.edges.build(source: @v3, target: @v4, weight: 3)
    @e4 = @graph.edges.build(source: @v4, target: @v5, weight: 4)
    @e5 = @graph.edges.build(source: @v5, target: @v6, weight: 5)
  end

  def test_path_vertices
    path = Rgraphum::Path.new(@v3, [@v1, @v2, @v3])
    assert_equal [@v1, @v2, @v3], path.vertices
  end

  def test_path_total_weight
    path = Rgraphum::Path.new(@v2, [@v1, @v2])
    assert_equal 1, path.total_weight

    path = Rgraphum::Path.new(@v3, [@v1, @v2, @v3])
    assert_equal 3, path.total_weight

    path = Rgraphum::Path.new(@v4, [@v1, @v2, @v3, @v4])
    assert_equal 6, path.total_weight

    path = Rgraphum::Path.new(@v4, [@v1, @v2, @v3, @v4, @v5])
    assert_equal 10, path.total_weight

    path = Rgraphum::Path.new(@v6, [@v1, @v2, @v3, @v4, @v5, @v6])
    assert_equal 15, path.total_weight
  end
end
