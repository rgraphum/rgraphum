# coding: utf-8

require 'test_helper'
require 'rgraphum'

class PathGraphTest < MiniTest::Unit::TestCase
  def setup
    @meme_tracker = make_base_phrase_graph
    @graph = make_sample_graph_for_cluster
    @meme_tracker.graph = @graph
    @vertices = @meme_tracker.graph.vertices
  end

  #        __(4)___(8)___
  #       /     ___/     (13)
  #    (1)___  |____(9)__/
  #          (5)___
  #       ___/     (10)__
  #    (2)___   __/    __(14)
  #   /   ___(6)___   /
  #  | (3)___   ___(11)
  #   \______(7)_________(15)
  #                (12)__/
  #
  #
  #         (3)/--(2)   (1)
  #         / X   / \   / \
  #        / / \ /   \ /   \
  #       (7)  (6)   (5)   (4)
  #       /  \ / \  /  \    |
  # (12) /  (11) (10) (9)  (8)
  #   \ /      \ /      \  /
  #   (15)     (14)     (13)
  #

  def test_path_graph
    path_graphs = Rgraphum::Analyzer::PathGraph.build(@graph)
    # please see under test of fint_path

    assert_equal 4, path_graphs.size

    expected = [
      {id: 1},
      {id: 4},
      {id: 5},
      {id: 8},
      {id: 9},
      {id: 10},
      {id: 13},
      {id: 14},
    ]
    assert_equal expected, path_graphs[0].vertices.sort_by(){|vertex| vertex.id}

    expected = [
      {id: 1,  source: 1, target: 4,  weight: 1},
      {id: 2,  source: 1, target: 5,  weight: 1},
      {id: 8,  source: 4, target: 8,  weight: 1},
      {id: 10, source: 5, target: 9,  weight: 1},
      {id: 11, source: 5, target: 10, weight: 1},
      {id: 16, source: 8, target: 13, weight: 1},
      {id: 18, source: 10,target: 14, weight: 1},
    ]
    assert_equal expected, path_graphs[0].edges.sort_by(){|edge| edge.id}
  end

  # 1 -> 2 -> 3 -> 4
  #      ^    |
  #      |   \|
  # 5 -> 6 -> 7
  #      ^
  #      |
  # 8 -> 9

  ###

  # 1 -> 2 -> 3 -> 4
  #           |
  #          \|
  # 5 -> 6    7

  #      2 -> 3 -> 4
  #      ^    |
  #      |   \|
  # 5 -> 6    7

  # 
  #     
  # 8 -> 9

  def test_find_path_to_all_end_root_vertices
    g = Rgraphum::Graph.new
    v_1 = g.vertices.build( { id:1 } )
    v_2 = g.vertices.build( { id:2 } )
    v_3 = g.vertices.build( { id:3 } )
    v_4 = g.vertices.build( { id:4 } )
    v_5 = g.vertices.build( { id:5 } )
    v_6 = g.vertices.build( { id:6 } )
    v_7 = g.vertices.build( { id:7 } )
    v_8 = g.vertices.build( { id:8 } )
    v_9 = g.vertices.build( { id:9 } )

    e_1 = g.edges.build( source:1, target:2)
    e_2 = g.edges.build( source:2, target:3)
    e_3 = g.edges.build( source:3, target:4)

    e_4 = g.edges.build( source:5, target:6)
    e_6 = g.edges.build( source:6, target:7)
    e_5 = g.edges.build( source:6, target:2)
    e_7 = g.edges.build( source:3, target:7)

    e_9 = g.edges.build( source:9, target:6)
    e_8 = g.edges.build( source:8, target:9)

     v_1_g = Rgraphum::Analyzer::MemeTracker.new.find_path(source_vertex:v_1).to_graph
     Rgraphum::Parsers::GraphvizParser.export(v_1_g,"v_1_g","jpg")

     v_5_g = Rgraphum::Analyzer::MemeTracker.new.find_path(source_vertex:v_5).to_graph
     Rgraphum::Parsers::GraphvizParser.export(v_5_g,"v_5_g","jpg")

     v_8_g = Rgraphum::Analyzer::MemeTracker.new.find_path(source_vertex:v_8).to_graph
     Rgraphum::Parsers::GraphvizParser.export(v_8_g,"v_8_g","jpg")
  end

  def test_cut_edges_with_srn
    @graph = Rgraphum::Analyzer::MemeTracker.new.cut_edges_with_srn(@graph)
    @graph.edges.sort_by{|edge| edge.id }.each do |edge|
      
    end
  end

  private

  def make_base_phrase_graph
    phrase_array = [
      { id:  1, words: %w{A} },
      { id:  2, words: %w{A} },
    ]
    Rgraphum::Analyzer::MemeTracker.new(phrase_array)
  end

  def make_sample_graph_for_cluster
    graph = Rgraphum::Graph.new
    graph.vertices = [
      {id:  1}, {id:  2}, {id:  3}, {id:  4}, {id:  5},
      {id:  6}, {id:  7}, {id:  8}, {id:  9}, {id: 10},
      {id: 11}, {id: 12}, {id: 13}, {id: 14}, {id: 15},
    ]
    graph.edges = [
      {source:  1, target:  4}, {source: 1, target:  5},
      {source:  2, target:  5}, {source: 2, target:  6}, {source: 2, target: 7},
      {source:  3, target:  6}, {source: 3, target:  7},
      {source:  4, target:  8},
      {source:  5, target:  8}, {source: 5, target:  9}, {source: 5, target: 10},
      {source:  6, target: 10}, {source: 6, target: 11},
      {source:  7, target: 11}, {source: 7, target: 15},
      {source:  8, target: 13},
      {source:  9, target: 13},
      {source: 10, target: 14},
      {source: 11, target: 14},
      {source: 12, target: 15},
    ]
    graph.edges.each { |edge| edge.weight = 1 }

    graph
  end
end
