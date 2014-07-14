# coding: utf-8

require 'test_helper'
require 'rgraphum'

class MemeTrackerTest < MiniTest::Unit::TestCase
  def setup
    @meme_tracker = make_base_phrase_graph
    @graph = make_sample_graph_for_cluster
    @meme_tracker.graph = @graph
    @vertices = @meme_tracker.graph.vertices
  end

  # some big method check
  def test_make_edges
    graph = Rgraphum::Graph.new
    phrases = [
      phrase_a = {id: 0, words: %w{私 は 山 が 好き}},
      phrase_b = {id: 1, words: %w{君 は 山 が 好き かな}},
      phrase_c = {id: 2, words: %w{僕 は 海 も 好き}}
    ]
    graph.vertices = phrases

    meme_tracker = Rgraphum::Analyzer::MemeTracker.new
    meme_tracker.make_edges(graph)

    edge = graph.edges[0]
    assert_equal 1,        edge.id
    assert_equal phrase_a, edge.source
    assert_equal phrase_b, edge.target
    assert_equal 1.0/3.0,  edge.weight

    edge = graph.edges[1]
    assert_equal 2,        edge.id
    assert_equal phrase_a, edge.source
    assert_equal phrase_c, edge.target
    assert_equal 1.0/4.0,  edge.weight

    edge = graph.edges[2]
    assert_equal 3,        edge.id
    assert_equal phrase_b, edge.source
    assert_equal phrase_c, edge.target
    assert_equal 1.0/5.0,  edge.weight
  end

  def test_count_same_words_vertices
    phrases = [
      phrase_a = {id: 0, words: %w{山 が 好き}},
      phrase_b = {id: 1, words: %w{山 が 好き}},
      phrase_c = {id: 2, words: %w{海 が 好き}},
    ]
    graph = Rgraphum::Graph.new
    graph.vertices = phrases

    meme_tracker = Rgraphum::Analyzer::MemeTracker.new
    meme_tracker.count_same_words_vertices(graph)

    assert_equal 1,   graph.vertices[0].count
    assert_nil graph.vertices[1].count
    assert_nil graph.vertices[2].count
  end

  def test_make_graph_some_of_functional
    phrases = [
      phrase_a = {words: %w{私 は 山 が 好き}},
      phrase_b = {words: %w{君 は 山 が 好き かな}},
      phrase_c = {words: %w{僕 は 海 も 好き}},
    ]

    meme_tracker = Rgraphum::Analyzer::MemeTracker.new
    graph = meme_tracker.make_graph(phrases)
    graph = make_sample_graph_for_cluster

    #<Rgraphum::Graph:0x00000003bb5e88 @vertices=[{:words=>["私", "は", "山", "が", "好き"], :id=>0, :count=>1}, {:words=>["君", "は", "山", "が", "好き", "かな"], :id=>1, :count=>1}, {:words=>["僕", "は", "海", "も", "好き"], :id=>2, :count=>1}], @edges=[{:source=>{:words=>["私", "は", "山", "が", "好き"], :id=>0, :count=>1}, :target=>{:words=>["君", "は", "山", "が", "好き", "かな"], :id=>1, :count=>1}, :weight=>0.3333333333333333, :id=>0}, {:source=>{:words=>["私", "は", "山", "が", "好き"], :id=>0, :count=>1}, :target=>{:words=>["僕", "は", "海", "も", "好き"], :id=>2, :count=>1}, :weight=>0.25, :id=>1}, {:source=>{:words=>["君", "は", "山", "が", "好き", "かな"], :id=>1, :count=>1}, :target=>{:words=>["僕", "は", "海", "も", "好き"], :id=>2, :count=>1}, :weight=>0.2, :id=>2}], @aspect="real">
  end

  def test_distance
    # distance of insert delete is 1
    assert_equal 1, @meme_tracker.edit_distance(%w{hoge},           %w{hoge huga})
    assert_equal 1, @meme_tracker.edit_distance(%w{hoge},           %w{huga hoge})
    assert_equal 1, @meme_tracker.edit_distance(%w{hoge piyo},      %w{hoge huga piyo})
    assert_equal 1, @meme_tracker.edit_distance(%w{hoge huga piyo}, %w{hoge piyo})

    # distance of change is 1
    assert_equal 1, @meme_tracker.edit_distance(%w{hoge huga piyo}, %w{hxge huga piyo})
    assert_equal 1, @meme_tracker.edit_distance(%w{hoge huga piyo}, %w{hoge hxga piyo})
    assert_equal 1, @meme_tracker.edit_distance(%w{hoge huga piyo}, %w{hoge huga pxyo})

    # change of potion is 2
    assert_equal 2, @meme_tracker.edit_distance(%w{hoge huga piyo}, %w{huga hoge piyo})
    assert_equal 2, @meme_tracker.edit_distance(%w{hoge huga piyo}, %w{hoge piyo huga})
    assert_equal 2, @meme_tracker.edit_distance(%w{hoge huga piyo}, %w{piyo huga hoge})

    base_array = %w{hoge huga piyo puyo}
    # distance of 2 insert
    base_array.combination(2) do |pair|
      assert_equal 2, @meme_tracker.edit_distance(pair, base_array)
    end
    # distance of 2 insert
    base_array.combination(2) do |pair|
      assert_equal 2, @meme_tracker.edit_distance(base_array, pair)
    end

    # complex test
    assert_equal 1, @meme_tracker.edit_distance(%w{A B D D},               %w{A C B D D})
    assert_equal 2, @meme_tracker.edit_distance(%w{A B D D D},             %w{A C D B D})
    assert_equal 3, @meme_tracker.edit_distance(%w{A B A A A B A A A A A}, %w{B A A B A A A A})

    # big diff test
    assert_equal 4, @meme_tracker.edit_distance(%w{A C C C C}, %w{A D D D D})
    assert_equal 4, @meme_tracker.edit_distance(%w{C A D C C}, %w{A D D D D})
    assert_equal 4, @meme_tracker.edit_distance(%w{C C A D C}, %w{A D D D D})
    assert_equal 4, @meme_tracker.edit_distance(%w{C C C A D}, %w{A D D D D})
    assert_equal 4, @meme_tracker.edit_distance(%w{D D C C A}, %w{A D D D D})

    # big diff test
    assert_equal 5, @meme_tracker.edit_distance(%w{A C C C C C}, %w{A D D D D D})
    assert_equal 5, @meme_tracker.edit_distance(%w{C A D C C C}, %w{A D D D D D})
    assert_equal 5, @meme_tracker.edit_distance(%w{C C A D C C}, %w{A D D D D D})
    assert_equal 5, @meme_tracker.edit_distance(%w{C C C A D C}, %w{A D D D D D})
    assert_equal 5, @meme_tracker.edit_distance(%w{C C C C A D}, %w{A D D D D D})

    assert_equal 2, @meme_tracker.edit_distance(%w{F A B C D E}, %w{A B C D E F})
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
  def test_phrase_clusters_1
    #####################################
    # test start_vertices and end_vertices
    start_root_vertices = @meme_tracker.start_root_vertices
    assert_equal [{id: 1}, {id: 2}, {id: 3}, {id: 12}], start_root_vertices

    end_root_vertices = @meme_tracker.end_root_vertices
    assert_equal [{id: 13}, {id: 14}, {id: 15}], end_root_vertices
  end

  def test_phrase_clusters_2
    ###################################
    # test for find path from start vertices
    start_vertex = @graph.vertices.where(id: 8).first
    cluster = @meme_tracker.build_end_root_vertex_path_hash(start_vertex)
    path = cluster[{id: 13}]
    assert_equal([{id: 8}, {id: 13}], path)

    start_vertex = @graph.vertices.where(id: 9).first
    cluster = @meme_tracker.build_end_root_vertex_path_hash(start_vertex)
    path = cluster[{id: 13}]
    assert_equal([{id: 9}, {id: 13}],path)

    start_vertex = @graph.vertices.where(id: 4).first
    cluster = @meme_tracker.build_end_root_vertex_path_hash(start_vertex)
    path = cluster[{id: 13}]
    assert_equal([{id: 4}, {id: 8}, {id: 13}], path)

    start_vertex = @graph.vertices.where(id: 5).first
    cluster = @meme_tracker.build_end_root_vertex_path_hash(start_vertex)
    expected = {
      13 => [{id:  5}, {id: 8},  {id: 13}, {id: 9}],
      14 => [{id:  5}, {id: 10}, {id: 14}],
    }
    assert_equal expected[13], cluster[{id: 13}]
    assert_equal expected[14], cluster[{id: 14}]

    start_vertex = @graph.vertices.where(id: 1).first
    cluster = @meme_tracker.build_end_root_vertex_path_hash(start_vertex)
    expected = {
      13 => [{id: 1}, {id: 4}, {id:  8}, {id: 13}, {id: 5}, {id: 9} ],
      14 => [{id: 1}, {id: 5}, {id: 10}, {id: 14}],
    }
    assert_equal expected[13], cluster[{id: 13}]
    assert_equal expected[14], cluster[{id: 14}]
  end

  def test_phrase_clusters_4
    ###################################
    # test for one cluster make on graph

    end_root_vertices   = @meme_tracker.end_root_vertices
    end_vertex = end_root_vertices[0] # (13)
    start_vertex = @graph.vertices.where(id: 8).first
    cluster = @meme_tracker.find_cluster(start_vertex, end_vertex)
    assert_equal [{id: 8}, {id: 13}], cluster

    start_vertex = @graph.vertices.where(id: 9).first
    cluster = @meme_tracker.find_cluster(start_vertex, end_vertex)
    assert_equal [{id: 9}, {id: 13}], cluster

    start_vertex = @graph.vertices.where(id: 4).first
    cluster = @meme_tracker.find_cluster(start_vertex, end_vertex)
    assert_equal [{id: 4}, {id: 8}, {id: 13}], cluster

    start_vertex = @graph.vertices.where(id: 1).first
    cluster = @meme_tracker.find_cluster(start_vertex, end_vertex)
    assert_equal [{id: 1}, {id: 4}, {id: 8}, {id: 13}, {id: 5}, {id: 9}], cluster
  end

  def test_phrase_clusters_5
    ###################################
    # test for multi cluster make on graph

    # 1,2 -> 13 3 => 14, 12 -> 15
    start_root_vertices = [ @vertices.where(id: 1).first,  @vertices.where(id: 2).first,  @vertices.where(id: 3).first,  @vertices.where(id: 12).first ]
    end_root_vertices   = [ @vertices.where(id: 13).first, @vertices.where(id: 13).first, @vertices.where(id: 14).first, @vertices.where(id: 15).first ]
    clusters_a = @meme_tracker.make_communities(start_root_vertices,end_root_vertices)
    expected = [
      [ {:id =>  1}, {:id =>  4}, {:id =>  8}, {:id => 13}, {:id => 5}, {:id =>  9}, {:id => 2} ],
      [ {:id =>  3}, {:id =>  6}, {:id => 10}, {:id => 14}, {:id => 7}, {:id => 11} ],
      [ {:id => 12}, {:id => 15} ],
    ]
    # rg_assert_equal expected, clusters_a
    (0...expected.size).each do |i|
      assert_equal expected[i], clusters_a[i].vertices
    end

    # sum_sigma_in
    assert_equal 16, @meme_tracker.sum_sigma_in(clusters_a)
  end

  def test_phrase_clusters_6
    ##
    # 1 -> 13 2,3 -> 14, 12 -> 15
    start_root_vertices = [ @vertices.where(id: 1).first,  @vertices.where(id: 2).first,  @vertices.where(id: 3).first,  @vertices.where(id: 12).first ]
    end_root_vertices   = [ @vertices.where(id: 13).first, @vertices.where(id: 14).first, @vertices.where(id: 14).first, @vertices.where(id: 15).first ]
    clusters_b = @meme_tracker.make_communities(start_root_vertices, end_root_vertices)
    expected = [
      [ {:id =>  1}, {:id =>  4}, {:id => 8},  {:id => 13}, {:id => 5}, {:id =>  9} ],
      [ {:id =>  2}, {:id => 10}, {:id => 14}, {:id =>  6}, {:id => 7}, {:id => 11}, {:id => 3} ],
      [ {:id => 12}, {:id => 15} ],
    ]
    (0...expected.size).each do |i|
      assert_equal expected[i], clusters_b[i].vertices
    end

    # sum_sigma_in
    assert_equal 17, @meme_tracker.sum_sigma_in(clusters_b)

    clusters = @meme_tracker.phrase_clusters
    assert clusters
    assert_equal 3, clusters.size

    (0...clusters_b.size).each do |i|
      assert_equal clusters_b[i].vertices, clusters[i].vertices
    end
  end

  def test_phrase_clusters_7
    # 1 -> 13 2,3,12 -> 15
    start_root_vertices = [ @vertices.where(id: 1).first,  @vertices.where(id: 2).first,  @vertices.where(id: 3).first,  @vertices.where(id: 12).first ]
    end_root_vertices   = [ @vertices.where(id: 13).first, @vertices.where(id: 15).first, @vertices.where(id: 15).first, @vertices.where(id: 15).first ]
    clusters_c = @meme_tracker.make_communities(start_root_vertices, end_root_vertices)
    expected = [
      [ {:id => 1}, {:id => 4}, {:id =>  8}, {:id => 13}, {:id =>  5}, {:id => 9} ],
      [ {:id => 2}, {:id => 7}, {:id => 15}, {:id =>  3}, {:id => 12} ],
    ]
    (0...expected.size).each do |i|
      assert_equal expected[i], clusters_c[i].vertices
    end

    # sum_sigma_in
    assert_equal 11, @meme_tracker.sum_sigma_in(clusters_c)
  end

  def test_phrase_clusters_8
    # 1 -> 13 2,3 -> 14, 12 => 15
    start_root_vertices = [ @vertices.where(id: 1).first,  @vertices.where(id: 2).first,  @vertices.where(id: 3).first,  @vertices.where(id: 12).first ]
    end_root_vertices   = [ @vertices.where(id: 13).first, @vertices.where(id: 14).first, @vertices.where(id: 14).first, @vertices.where(id: 15).first ]
    clusters_d = @meme_tracker.make_communities(start_root_vertices, end_root_vertices)
    expected = [
      [ {:id =>  1}, {:id =>  4}, {:id => 8},  {:id => 13}, {:id => 5}, {:id =>  9} ],
      [ {:id =>  2}, {:id => 10}, {:id => 14}, {:id =>  6}, {:id => 7}, {:id => 11}, {:id  => 3} ],
      [ {:id => 12}, {:id => 15} ],
    ]
    (0...expected.size).each do |i|
      assert_equal expected[i], clusters_d[i].vertices
    end
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
