# -*- coding: utf-8 -*-

require 'rgraphum'
require 'test_helper'

class RgraphumGremlinTest < MiniTest::Unit::TestCase
  # FIXME
  class Rgraphum::Vertex
    field :name, :age, :lang
  end

  def setup
    make_gremlin_sample
  end

  def test_v
    rg_assert_equal ({id:1,name:"marko", age:29}), @graph.v(1)
    rg_assert_equal [{id:1,name:"marko",age:29},{id:2,name:"vadas",age:27},{id:3,name:"lop",lang:"java"}], @graph.v(1,2,3)
    rg_assert_equal [{id:1,name:"marko",age:29},{id:2,name:"vadas",age:27},{id:3,name:"lop",lang:"java"}], @graph.v([1,2,3])
  end

  def test_e
    assert_equal 10, @graph.e(10).id
    assert_equal [10,11,12], @graph.e(10,11,12).id
    assert_equal [10,11,12], @graph.e([10,11,12]).id
  end

  def test_addVertex
    g = Rgraphum::Graph.new
    rg_assert_equal({id:0}, g.addVertex())
    rg_assert_equal({id:100}, g.addVertex(100))

    rg_assert_equal({id:101,name:"stephen"}, g.addVertex(nil,{name:"stephen"}))
  end

  def test_addEdge
    g = Rgraphum::Graph.new
    v1 = g.addVertex(100)
    v2 = g.addVertex(200)

    e = g.addEdge(v1,v2,'friend')
    rg_assert_equal v1, e.outV
    rg_assert_equal v2, e.inV

    e = g.addEdge(1000,v1,v2,'friend')
    rg_assert_equal({:id=>1000, :source=>{:id=>100}, :target=>{:id=>200}, :label=>"friend", :weight=>1}, e)

    e = g.addEdge(nil,v1,v2,'friend',{weight:0.75})
    rg_assert_equal({:id=>1001, :source=>{:id=>100}, :target=>{:id=>200}, :label=>"friend", :weight=>0.75}, e)
    
  end

  def test_both
    v = @graph.v(4)
    rg_assert_equal [{id:1,name:"marko",age:29},{id:5,name:"ripple",lang:"java"},{id:3,name:"lop",lang:"java"}], v.both
    rg_assert_equal [{id:1,name:"marko",age:29}], v.both('knows')
    rg_assert_equal [{id:1,name:"marko",age:29},{id:5,name:"ripple",lang:"java"},{id:3,name:"lop",lang:"java"}], v.both('knows','created')
  end

  def test_bothE
    v = @graph.v(4)
    assert_equal [8,10,11], v.bothE.id
    assert_equal [8], v.bothE('knows').id
    assert_equal [8,10,11], v.bothE('knows','created').id
  end

  def test_outV_inV_both_V
    e = @graph.e(12)
    rg_assert_equal({id:6,name:"peter",age:35}, e.outV)
    rg_assert_equal({id:3,name:"lop",lang:"java"}, e.inV)
    rg_assert_equal [{id:6,name:"peter", age:35},{id:3,name:"lop",lang:"java"}], e.bothV
  end

  def test_id
    v = @graph.V(:name,"marko")
    assert_equal [1], v.id

    v[0].id = 2000
    assert_equal [2000], v.id
  end

  def test_V
    assert_equal [1,2,3,4,5,6], @graph.V.id
    rg_assert_equal [{id:1,name:"marko",age:29}], @graph.V(:name,"marko")
    assert_equal ["marko"], @graph.V(:name,"marko").name
  end

  def test_E
    assert_equal [7,8,9,10,11,12], @graph.E.id
    assert_equal [0.5,1.0,0.4,1.0,0.4,0.2], @graph.E.weight
  end

  def test_in_inE
    v = @graph.v(4)
    rg_assert_equal [{id:1,name:"marko",age:29}], v.inE.outV
    rg_assert_equal [{id:1,name:"marko",age:29}], v.in

    v = @graph.v(3)
    rg_assert_equal [{id:1,name:"marko",age:29},{id:4,name:"josh",age:32},{id:6,name:"peter", age:35}], v.in('created')
    rg_assert_equal [{id:1,name:"marko",age:29},{id:4,name:"josh",age:32},{id:6,name:"peter", age:35}], v.inE('created').outV
  end

  def test_out_outE
    v = @graph.v(1)
    rg_assert_equal [{id:2,name:"vadas",age:27},{id:4,name:"josh",age:32},{id:3,name:"lop",lang:"java"}], v.outE.inV
    rg_assert_equal [{id:2,name:"vadas",age:27},{id:4,name:"josh",age:32},{id:3,name:"lop",lang:"java"}], v.out

    rg_assert_equal [{id:2,name:"vadas",age:27},{id:4,name:"josh",age:32}], v.outE('knows').inV
    rg_assert_equal [{id:2,name:"vadas",age:27},{id:4,name:"josh",age:32}], v.out('knows')
  end

  def test_has
    assert_equal ["marko"],         @graph.V.has(:name, "marko").name
    assert_equal [0.5,1.0],         @graph.v(1).outE.has(:weight, Rgraphum::T.gte, 0.5 ).weight
    assert_equal ["marko", "vadas", "josh", "peter"], @graph.V.has("age").name
    assert_equal ["lop", "ripple"], @graph.V.has("age", nil ).name
  end

  def test_has_not
    assert_equal [1.0,0.4],                           @graph.v(1).outE.hasNot(:weight, Rgraphum::T.eq, 0.5 ).weight
    assert_equal ["marko", "vadas", "josh", "peter"], @graph.V.hasNot("age", nil ).name
  end

  private

  def make_gremlin_sample
    @graph = Rgraphum::Graph.new

    # add vertices
    @graph.vertices << {id:1,name:"marko", age:29            }
    @graph.vertices << {id:2,name:"vadas", age:27            }
    @graph.vertices << {id:3,name:"lop",          lang:"java"}
    @graph.vertices << {id:4,name:"josh",  age:32            }
    @graph.vertices << {id:5,name:"ripple",       lang:"java"}
    @graph.vertices << {id:6,name:"peter", age:35}

    # add vertices
    @graph.edges << {id:7, label:"knows",  weight:0.5,source:1,target:2}
    @graph.edges << {id:8, label:"knows",  weight:1.0,source:1,target:4}
    @graph.edges << {id:9, label:"created",weight:0.4,source:1,target:3}
    @graph.edges << {id:10,label:"created",weight:1.0,source:4,target:5}
    @graph.edges << {id:11,label:"created",weight:0.4,source:4,target:3}
    @graph.edges << {id:12,label:"created",weight:0.2,source:6,target:3}
  end
end
