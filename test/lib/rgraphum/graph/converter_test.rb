# -*- coding: utf-8 -*-

require 'rgraphum'
require 'test_helper'

class RgraphumConverterTest < MiniTest::Unit::TestCase
  def setup
    @graph = Rgraphum::Graph.new
    @graph.vertices << { id: 1, label: "hoge" }
    @graph.vertices << { id: 2, label: "huga" }

    @vertex0, @vertex1 = @graph.vertices
    @vertex0.edges << { source: @vertex0, target: @vertex1 }

    @edge0 = @graph.edges[0]
  end

  def test_undirected
    graph = Rgraphum::Graph::Converter.to_undirected(@graph)

    assert_equal 2, graph.edges.size
    assert_equal 1, graph.vertices[0].out_edges.size
    assert_equal 1, graph.vertices[0].in_edges.size
    assert_equal 1, graph.vertices[1].out_edges.size
    assert_equal 1, graph.vertices[1].in_edges.size

    assert_equal graph.edges[0].source, graph.edges[1].target 
    assert_equal graph.edges[0].target, graph.edges[1].source
    assert_equal graph.edges[0].weight, graph.edges[1].weight

  end

end
