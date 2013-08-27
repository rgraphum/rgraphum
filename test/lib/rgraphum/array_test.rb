# -*- coding: utf-8 -*-

require 'rgraphum'
require 'test_helper'

class RgraphumArrayTest < MiniTest::Test
  def setup
    @graph = Rgraphum::Graph.new
  end

  def test_vertex_in_E_in_outE_out
    @graph.vertices = [
      {:id => 1, :label => "hoge" },
      {:id => 2, :label => "huga" },
    ]
    @graph.edges = [{id: 1, source: 1, target: 2}]

    # rg_assert_equal [{id:1, source: {id:1, label:"hoge"}, target:{id: 2, label: "huga"}}], @graph.vertices[0].edges
    assert_equal 1, @graph.vertices[0].edges.size
    assert_equal 1, @graph.vertices[0].edges[0].id
    rg_assert_equal({id: 1, label: "hoge"}, @graph.vertices[0].edges[0].source)
    rg_assert_equal({id: 2, label: "huga"}, @graph.vertices[0].edges[0].target)

    assert_empty @graph.vertices[0].inE
    assert_empty @graph.vertices[0].in
    # rg_assert_equal [{ id:1, source: {id:1,label:"hoge"}, target:{id:2,label:"huga"} }], @graph.vertices[0].outE
    assert_equal 1, @graph.vertices[0].outE.size
    assert_equal 1, @graph.vertices[0].outE[0].id
    rg_assert_equal({id:1,label:"hoge"}, @graph.vertices[0].outE[0].source)
    rg_assert_equal({id:2,label:"huga"}, @graph.vertices[0].outE[0].target)

    rg_assert_equal [{id:2,label:"huga"}], @graph.vertices[0].out

    assert_empty @graph.vertices[1].outE
    assert_empty @graph.vertices[1].out
    # rg_assert_equal [{id:1, source: {id:1,label:"hoge"}, target:{id:2,label:"huga"} }], @graph.vertices[1].inE
    assert_equal 1, @graph.vertices[1].inE.size
    assert_equal 1, @graph.vertices[1].inE[0].id
    rg_assert_equal({id: 1,label: "hoge"}, @graph.vertices[1].inE[0].source)
    rg_assert_equal({id: 2,label: "huga"}, @graph.vertices[1].inE[0].target)
    rg_assert_equal [{id:1,label:"hoge"}], @graph.vertices[1].in
  end

  def test_start_root_vertices
    @graph.vertices = [
      { id: 1, label: "a" },
      { id: 2, label: "b" },
      { id: 3, label: "c" },
      { id: 4, label: "d" },
      { id: 5, label: "e" },
      { id: 6, label: "f" },
      { id: 7, label: "g" },
      { id: 8, label: "h" },
      { id: 9, label: "i" },
    ]
    @graph.edges = [
      { source: 1, target: 2 }, # *1 "a"
      { source: 2, target: 3 },
      { source: 3, target: 4 },
      { source: 5, target: 4 }, # *5 "e"
      { source: 3, target: 6 },
      { source: 7, target: 6 }, # *7 "g"
      { source: 7, target: 8 },
      #                         # *9 "i"
    ]

    assert_equal ["a", "e", "g", "i"], @graph.start_root_vertices.map(&:label)
  end

  def test_end_root_vertices
    @graph.vertices = [
      { id: 1, label: "a" },
      { id: 2, label: "b" },
      { id: 3, label: "c" },
      { id: 4, label: "d" },
      { id: 5, label: "e" },
      { id: 6, label: "f" },
      { id: 7, label: "g" },
      { id: 8, label: "h" },
      { id: 9, label: "i" },
    ]
    @graph.edges = [
      { source: 1, target: 2 },
      { source: 2, target: 3 },
      { source: 3, target: 4 }, # *4 "d"
      { source: 5, target: 4 },
      { source: 3, target: 6 }, # *6 "f"
      { source: 7, target: 6 },
      { source: 7, target: 8 }, # *8 "h"
      #                         # *9 "i"
    ]

    assert_equal ["d", "f", "h", "i"], @graph.end_root_vertices.map(&:label)
  end
end
