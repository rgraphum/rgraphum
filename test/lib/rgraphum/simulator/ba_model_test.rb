# coding: utf-8

require 'test_helper'
require 'rgraphum'

class BAModelTest < MiniTest::Test
  def setup
    make_graph
  end

  def test_simurate
    
  end

  def test_edges_per_min
    # 99 * 99 * 20 - 20 = 196_000 sec
    # 196_000 / 60 min
    ba = Rgraphum::Simulator::BAModel.new
    assert_equal 99 / ( 196_000 / 60.0 ) , ba.edges_per_min(@graph)    
  end

  def test_vertices_per_min
    # 99 * 99 * 20 = 196_020 sec
    # 196_020 / 60 = 3_267 min
    ba = Rgraphum::Simulator::BAModel.new
    assert_equal 100.0 / 3_267 , ba.vertices_per_min(@graph)
  end

  def test_edges_size_array_per_interval
    ba = Rgraphum::Simulator::BAModel.new

    mini_graph = Rgraphum::Graph.new
    base_time = ( Time.now.to_i / 60 ) * 60
    mini_graph.vertices = [ {id: 1,start: Time.now},{id: 2,start: Time.now},{id: 3,start: Time.now}]
    mini_graph.edges = [ {id: 1,start: base_time + 30,     source: 1,target: 2 },
                         {id: 2,start: base_time + 90,     source: 2,target: 3 },
                         {id: 3,start: base_time + 60 * 2, source: 3,target: 1 } ]

    array = ba.edges_size_array_per_interval( mini_graph, 1 )
    assert_equal [1,1,1], array

    mini_graph.edges.delete(3)
    array = ba.edges_size_array_per_interval( mini_graph, 1 )
    assert_equal [1,1], array

    array = ba.edges_size_array_per_interval( @graph, 1 )

    assert_equal 3268, array.size
    assert_equal 99,   array.inject(:+)
  end

private
  def make_graph
    today = Time.at( ( Time.now.to_i/ ( 3600 * 24 ) ) * 3600 * 24 - Time.now.utc_offset )

    @graph = Rgraphum::Graph.new

    vertices = 100.times.map do |t|
      {id: t, label: t.to_s, start: today + 20 * t * t }
    end

    @graph.vertices = vertices

    edges = @graph.vertices.map do |vertex|
      {id: vertex.id,source: @graph.vertices[0], target: vertex, start: vertex.start, weight: 1}
    end
    
    @graph.edges = edges

    @graph.edges.delete(0)

    @graph
  end

end
