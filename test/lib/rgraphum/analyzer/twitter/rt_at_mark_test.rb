# coding: utf-8

require 'test_helper'
require 'rgraphum'
require 'csv'

class RTAtMarkTest < MiniTest::Unit::TestCase
  def setup
    twits
  end

  def test_make_graph
    at = Rgraphum::Analyzer::RTAtMark.new
    graph = at.make_graph(@twits)

    assert_equal 4, graph.vertices.size

    vertex = graph.vertices.detect { |vertex| vertex.id == 0 }
    assert vertex
    rg_assert_equal({id: 0, label: "piyo",
                         twits: [["221257277779353600", "piyo", "I remember it",    "2013-04-04 15:30:00", "ja"],
                                 ["221257277779353602", "piyo", "I like it",        "2013-04-04 15:30:00", "ja"],
                                 ["221257277779353605", "piyo", "I forget it",      "2013-04-04 15:30:00", "ja"],
                                 ["221257277779353605", "piyo", "@hura I forget it","2013-04-04 15:30:00", "ja"]]}, vertex )
    vertex = graph.vertices.detect { |vertex| vertex.id == 1 }
    assert vertex
    rg_assert_equal({id: 1, label: "hoge",
                         twits: [["221257277779353601","hoge","@hoge remember me!","2013-01-01 12:00:00","ja"],
                                 ["221257277779353604","hoge","Jast me @huga Do you mean @Hoge remember me!","2013-03-03 14:20:00","ja"]]}, vertex)

    vertex = graph.vertices.detect { |vertex| vertex.id == 2 }
    assert vertex
    rg_assert_equal({id: 2, label: "huga",
                         twits: [["221257277779353603","huga","Do you mean @hoge remember me!","2013-02-02 13:10:00","ja"],
                                 ["221257277779353604","huga","Do you mean @Hoge remember me!","2013-03-03 14:20:00","ja"]]}, vertex)

    vertex = graph.vertices.detect { |vertex| vertex.id == 3 }
    assert vertex
    rg_assert_equal({id: 3, label: "hura"}, vertex)
  
    assert_equal 5, graph.edges.size

    edge = graph.edges.detect { |edge| edge.id == 0 }
    assert edge
    expected_edge = {id: 0, source: graph.vertices[1], target: graph.vertices[1], label: "@hoge remember me!", weight: 1}
    assert_equal(expected_edge[:source].id, edge.source.id)
    assert_equal(expected_edge[:target].id, edge.target.id)
    assert_equal(expected_edge[:label],     edge.label)
    assert_equal(expected_edge[:weight],    edge.weight)

    edge = graph.edges.detect { |edge| edge.id == 1 }
    assert edge
    expected_edge = {id: 1, source: graph.vertices[1], target: graph.vertices[2], label: "Do you mean @hoge remember me!", weight: 1}
    assert_equal(expected_edge[:source].id, edge.source.id)
    assert_equal(expected_edge[:target].id, edge.target.id)
    assert_equal(expected_edge[:label],     edge.label)
    assert_equal(expected_edge[:weight],    edge.weight)

    edge = graph.edges.detect { |edge| edge.id == 2 }
    assert edge
    expected_edge = {id: 2, source: graph.vertices[1], target: graph.vertices[2], label: "Do you mean @Hoge remember me!", weight: 1}
    assert_equal(expected_edge[:source].id, edge.source.id)
    assert_equal(expected_edge[:target].id, edge.target.id)
    assert_equal(expected_edge[:label],     edge.label)
    assert_equal(expected_edge[:weight],    edge.weight)

    edge = graph.edges.detect { |edge| edge.id == 3 }
    assert edge
    expected_edge = {id: 3, source: graph.vertices[2], target: graph.vertices[1], label: "Jast me @huga Do you mean @Hoge remember me!", weight: 1}
    assert_equal(expected_edge[:source].id, edge.source.id)
    assert_equal(expected_edge[:target].id, edge.target.id)
    assert_equal(expected_edge[:label],     edge.label)
    assert_equal(expected_edge[:weight],    edge.weight)

    edge = graph.edges.detect { |edge| edge.id == 4 }
    assert edge
    expected_edge = {id: 4, source: graph.vertices[3], target: graph.vertices[0], label: "@hura I forget it", weight: 1}
    assert_equal(expected_edge[:source].id, edge.source.id)
    assert_equal(expected_edge[:target].id, edge.target.id)
    assert_equal(expected_edge[:label],     edge.label)
    assert_equal(expected_edge[:weight],    edge.weight)
  end

  def test_pickup_screen_name
    at = Rgraphum::Analyzer::RTAtMark.new
    text = "@hoge huga"
    assert_equal "hoge", at.pickup_screen_name(text)

    text = " @hoge huga"
    assert_equal "hoge", at.pickup_screen_name(text)

    text = "huga @hoge"
    assert_equal "hoge", at.pickup_screen_name(text)

    text = "(@hoge) huga"
    assert_equal "hoge", at.pickup_screen_name(text)

    text = "@hoge: huga"
    assert_equal "hoge", at.pickup_screen_name(text)

    text = "@Hoge_Huga"
    assert_equal "hoge_huga", at.pickup_screen_name(text)
  end

  private

  def twits
    @twits = [
      ["221257277779353600",nil,nil,nil,nil,nil,nil,"piyo","I remember it"                               ,nil,nil,"2013-04-04 15:30:00","ja",nil],
      ["221257277779353601",nil,nil,nil,nil,nil,nil,"hoge","@hoge remember me!"                          ,nil,nil,"2013-01-01 12:00:00","ja",nil],
      ["221257277779353602",nil,nil,nil,nil,nil,nil,"piyo","I like it"                                   ,nil,nil,"2013-04-04 15:30:00","ja",nil],
      ["221257277779353603",nil,nil,nil,nil,nil,nil,"huga","Do you mean @hoge remember me!"              ,nil,nil,"2013-02-02 13:10:00","ja",nil],
      ["221257277779353604",nil,nil,nil,nil,nil,nil,"huga","Do you mean @Hoge remember me!"              ,nil,nil,"2013-03-03 14:20:00","ja",nil],
      ["221257277779353604",nil,nil,nil,nil,nil,nil,"hoge","Jast me @huga Do you mean @Hoge remember me!",nil,nil,"2013-03-03 14:20:00","ja",nil],
      ["221257277779353605",nil,nil,nil,nil,nil,nil,"piyo","I forget it"                                 ,nil,nil,"2013-04-04 15:30:00","ja",nil],
      ["221257277779353605",nil,nil,nil,nil,nil,nil,"piyo","@hura I forget it"                           ,nil,nil,"2013-04-04 15:30:00","ja",nil]
    ]
  end

end
