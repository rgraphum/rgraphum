# -*- coding: utf-8 -*-

require 'rgraphum'
require 'test_helper'

class RgraphumTest < MiniTest::Unit::TestCase
  def setup
    make_test_graph
  end

  def test_constractor
    hash_vertices = [
      {id: 1, label: "hoge" },
      {id: 2, label: "huga" },
    ]
    hash_edges = [
      {id: 1, source: 1, target: 2, weight: 1},
      {id: 2, source: 2, target: 1, weight: 1},
    ]

    @graph = Rgraphum::Graph.new(vertices: hash_vertices, edges: hash_edges)

    assert_instance_of Rgraphum::Vertices, @graph.vertices
    assert_instance_of Rgraphum::Edges,    @graph.edges

    @graph.vertices.each do |vertex|
      assert_instance_of Rgraphum::Vertex, vertex
    end
    @graph.edges.each do |edge|
      assert_instance_of Rgraphum::Edge, edge
    end

    assert_equal @graph.vertices[0].edges[0].source.object_id, @graph.vertices[0].object_id
    assert_equal @graph.vertices[0].edges[1].source.object_id, @graph.vertices[1].object_id
    assert_equal @graph.vertices[1].edges[0].source.object_id, @graph.vertices[0].object_id
    assert_equal @graph.vertices[1].edges[1].source.object_id, @graph.vertices[1].object_id

    assert_equal @graph.vertices[0].edges[0].target.object_id, @graph.vertices[1].object_id
    assert_equal @graph.vertices[0].edges[1].target.object_id, @graph.vertices[0].object_id
    assert_equal @graph.vertices[1].edges[0].target.object_id, @graph.vertices[1].object_id
    assert_equal @graph.vertices[1].edges[1].target.object_id, @graph.vertices[0].object_id
  end

  def test_basic_method
    assert_instance_of Rgraphum::Vertices, @graph_a.vertices
    assert_instance_of Rgraphum::Edges,    @graph_a.edges

    assert @graph_a.vertices.graph
    assert @graph_a.edges.graph

    # 基本統計量
    assert_equal 2, @graph_a.m
    assert_equal 2, @graph_b.m
    assert_equal 2, @graph_a.m_with_weight
    assert_equal 4, @graph_b.m_with_weight
    assert_equal 2, @graph_a.average_degree
    assert_equal 2, @graph_b.average_degree

    # vertex_ids
    assert_equal [1, 2], @graph_a.vertices.id
    assert_equal 1, @graph_a.vertices.id.first
    assert_equal 2, @graph_a.vertices.id.last

    # edges
    edges = @graph_a.edges

    assert edges
    assert_equal 2, edges.size
    assert_same edges[0].target, edges[1].source
    assert_same edges[0].source, edges[1].target
    assert_same @graph_a.vertices[0], edges[0].source
    assert_same @graph_a.vertices[0], edges[1].target
    assert_same @graph_a.vertices[1], edges[1].source
    assert_same @graph_a.vertices[1], edges[0].target

    assert_equal 2, @graph_a.vertices[0].edges.size
    assert_equal 2, @graph_a.vertices[1].edges.size


    edge_ids = @graph_a.edges.id
    # edge_ids
    assert edge_ids
    assert_equal 1, edge_ids.first
    assert_equal 2, edge_ids.last

    base_id = @graph_a.vertices.current_id

    @graph_a.vertices = [{label: "hoge"}, {label: "hoge"}]
    vertices = @graph_a.vertices
    assert_equal [{id: base_id + 1 , label: "hoge"}, {id: base_id + 2 , label: "hoge"}], vertices
  end

  def test_delete_edge
    delete_edge = @graph_a.edges.where(id: 1).first
    remain_edge = @graph_a.edges.where(id: 2).first

    @graph_a.edges.delete(delete_edge)
    assert_equal ([remain_edge]), @graph_a.edges
    assert_equal ([remain_edge]), @graph_a.vertices[0].edges

    delete_edge = @graph_b.edges.where(id: 1).first
    remain_edge = @graph_b.vertices[0].edges.where(id: 2).first
    @graph_b.vertices[0].edges.delete(delete_edge)
    assert_equal ([remain_edge]), @graph_b.edges
    assert_equal ([remain_edge]), @graph_b.vertices[0].edges
  end

  def test_delete_edge_with_id
    remain_edge = @graph_a.edges.where(id: 2).first
    @graph_a.edges.delete(1)
    assert_equal ([remain_edge]), @graph_a.edges
    assert_equal ([remain_edge]), @graph_a.vertices[0].edges

    remain_edge = @graph_b.vertices[0].edges.where(id: 2).first
    @graph_b.vertices[0].edges.delete(1)
    assert_equal ([remain_edge]), @graph_b.edges
    assert_equal ([remain_edge]), @graph_b.vertices[0].edges
  end

  def test_vertex
    assert_equal 2, @graph_a.vertices[0].degree
    assert_equal 2, @graph_a.vertices[0].degree_weight
  end

  def test_find_by_some_key
    # find_by_labbel
    vertex = @graph_a.vertices.where(label: "hoge").first
    assert_equal @graph_a.vertices[0], vertex
    assert_same @graph_a.vertices[0], vertex
  end

  def test_where_condition
    vertex = @graph_a.vertices.where(label: "hoge").first
    assert_equal @graph_a.vertices[0].object_id, vertex.object_id
    assert_same @graph_a.vertices[0], vertex
  end

  def test_id_aspect!
    id_aspect_vertices =  @graph_a.vertices
    assert_equal [ {:id=>1, :label=>"hoge" }, {:id=>2, :label=>"huga"} ], id_aspect_vertices
    expected = [
      {:id=>1, :source=>1, :target=>2, :weight=>1 },
      {:id=>2, :source=>2, :target=>1, :weight=>1 },
    ]
    assert_equal expected, id_aspect_vertices[0].edges.map{ |edge| edge.to_h }
    expected = [
      {:id=>1, :source=>1, :target=>2, :weight=>1 },
      {:id=>2, :source=>2, :target=>1, :weight=>1 },
    ]
    assert_equal expected, id_aspect_vertices[1].edges
  end

  def test_real_aspect!
    real_aspect_vertices = @graph_a.vertices

    assert_equal 2, real_aspect_vertices.size
    assert_equal real_aspect_vertices[0].object_id, real_aspect_vertices[0].edges[0].source.object_id
    assert_equal real_aspect_vertices[1].object_id, real_aspect_vertices[0].edges[0].target.object_id
    assert_equal real_aspect_vertices[1].object_id, real_aspect_vertices[1].edges[1].source.object_id
    assert_equal real_aspect_vertices[0].object_id, real_aspect_vertices[1].edges[1].target.object_id
  end

  def test_add_vertex_with_no_id_added_id
    redis   = Redis.current
    base_id = redis.get( "global:RgraphumObjectId" ).to_i

    @graph = Rgraphum::Graph.new
    @graph.vertices = [{ :label => "huga" },{ :label => "huga" }]
    assert_equal ([ base_id+1, base_id+2 ] ), @graph.vertices.id

    @graph.vertices << { :label => "piyo" }
    assert_equal ( { :id => base_id + 3, :label => "piyo" } ), @graph.vertices.where(label: "piyo").first
    assert_equal ([base_id+1, base_id+2, base_id+3]), @graph.vertices.id
  end

  def test_add_edge_with_no_id_add_id
    #  0 - 1
    #   \ /
    #    2
    #   / \
    #  3 - 4

    # add edge to graph
    @graph = Rgraphum::Graph.new
    @graph.vertices = [
      { id: 0, label: "A", community_id: 1 },
      { id: 1, label: "B", community_id: 1 },
      {id:2,label:"C"},
      {id:3,label:"D"},
      {id:4,label:"E"},
    ]
    @graph.edges = [
      {source:0,target:1,weight:1},
      {source:0,target:2,weight:1},
      {source:1,target:2,weight:1},
      {source:2,target:3,weight:1},
      {source:2,target:4,weight:1},
      {source:3,target:4,weight:1},
    ]

#    @graph.id_aspect!
    assert_equal ( {id:1,source:0,target:1,weight:1} ), @graph.edges[0].to_h
    assert_equal ( {id:2,source:0,target:2,weight:1} ), @graph.edges[1].to_h
    assert_equal ( {id:3,source:1,target:2,weight:1} ), @graph.edges[2].to_h
    assert_equal ( {id:4,source:2,target:3,weight:1} ), @graph.edges[3].to_h
    assert_equal ( {id:5,source:2,target:4,weight:1} ), @graph.edges[4].to_h
    assert_equal ( {id:6,source:3,target:4,weight:1} ), @graph.edges[5].to_h

    # add edge to vertex
    @graph = Rgraphum::Graph.new
    @graph.vertices = [
      { id: 0, label: "A", community_id: 1 },
      { id: 1, label: "B", community_id: 1 },
      {id:2,label:"C"},
      {id:3,label:"D"},
      {id:4,label:"E"},
    ]
    @graph.vertices[0].edges << {source:0,target:1,weight:1}
    @graph.vertices[0].edges << {source:0,target:2,weight:1}
    @graph.vertices[1].edges << {source:1,target:2,weight:1}
    @graph.vertices[2].edges << {source:2,target:3,weight:1}
    @graph.vertices[2].edges << {source:2,target:4,weight:1}
    @graph.vertices[3].edges << {source:3,target:4,weight:1}

#    @graph.id_aspect!
    assert_equal({id:1,source:0,target:1,weight:1}, @graph.edges[0])
    assert_equal({id:2,source:0,target:2,weight:1}, @graph.edges[1])
    assert_equal({id:3,source:1,target:2,weight:1}, @graph.edges[2])
    assert_equal({id:4,source:2,target:3,weight:1}, @graph.edges[3])
    assert_equal({id:5,source:2,target:4,weight:1}, @graph.edges[4])
    assert_equal({id:6,source:3,target:4,weight:1}, @graph.edges[5])

  end

  def test_add_edge_with_id_aspect

    @graph = Rgraphum::Graph.new
    @graph.vertices = [{ :label => "hoge" },{:label => "huga"}]
    assert_equal ([{ :id => 1, :label => "hoge"}, {:id => 2, :label => "huga"}]), @graph.vertices

    @graph.edges << { :source => 2, :target => 1 }

#    @graph.id_aspect!
    assert_equal [ { :id => 1, :source => 2, :target => 1, :weight => 1}], @graph.edges.map { |edge| edge.to_h }.to_a

#    @graph.real_aspect!
    @graph.edges << { :source => 1, :target => 2 }
#    @graph.id_aspect!
    assert_equal ( { :id => 1, :source => 2, :target => 1, :weight => 1 } ), @graph.edges[0]
    assert_equal ( { :id => 2, :source => 1, :target => 2, :weight => 1 } ) , @graph.edges[1]
  end

  def test_edges_input_with_array
    @graph = Rgraphum::Graph.new
    @graph.vertices = [
      {:id => 1, :label => "hoge" },
      {:id => 2, :label => "huga" },
    ]
    @graph.edges = [
      {:source => 1, :target => 2, :weight => 1},
      {:source => 2, :target => 1, :weight => 1},
    ]
#    @graph.id_aspect!
    assert_equal [ {:id => 1, :source => 1, :target => 2, :weight => 1},{ :id => 2, :source => 2, :target => 1, :weight => 1}], @graph.edges.map{ |edge| edge.to_h }
  end

#  def test_divide_by_time
#    @graph = Rgraphum::Graph.new
#    @graph.vertices = [
#      {:id => 1, :label => "hoge", :start => Time.parse("2010-01-01 12:05"), :end => Time.parse("2010-01-01 12:05" )},
#      {:id => 2, :label => "huga", :start => Time.parse("2010-01-02 12:05"), :end => Time.parse("2010-01-02 13:35" )},
#    ]
#    @graph.edges = [
#      { :source => 1, :target => 2, :weight => 1, :start => Time.parse("2010-01-01 12:05"), :end => Time.parse("2010-01-01 12:05") },
#      { :source => 2, :target => 1, :weight => 1, :start => Time.parse("2010-01-02 12:05"), :end => Time.parse("2010-01-02 13:35") },
#      { :source => 2, :target => 1, :weight => 1, :start => Time.parse("2010-01-02 12:26"), :end => Time.parse("2010-01-02 13:19:59") },
#      { :source => 2, :target => 1, :weight => 1, :start => Time.parse("2010-01-02 12:40")                                            },
#    ]
#
#    @graph.divide_by_time
#
#    vertices = @graph.vertices.sort_by{ |vertex| vertex.start }
#    assert_equal "2010-01-01 12:00:00 +0900", vertices[0].start.to_s
#    assert_equal "2010-01-01 12:19:59 +0900", vertices[0].end.to_s
#
#    assert_equal "2010-01-02 12:00:00 +0900", vertices[1].start.to_s
#    assert_equal "2010-01-02 12:19:59 +0900", vertices[1].end.to_s
#
#    assert_equal "2010-01-02 12:20:00 +0900", vertices[2].start.to_s
#    assert_equal "2010-01-02 12:39:59 +0900", vertices[2].end.to_s
#
#    assert_equal "2010-01-02 12:40:00 +0900", vertices[3].start.to_s
#    assert_equal "2010-01-02 12:59:59 +0900", vertices[3].end.to_s
#
#    assert_equal "2010-01-02 13:00:00 +0900", vertices[4].start.to_s
#    assert_equal "2010-01-02 13:19:59 +0900", vertices[4].end.to_s
#
#    assert_equal "2010-01-02 13:20:00 +0900", vertices[5].start.to_s
#    assert_equal "2010-01-02 13:39:59 +0900", vertices[5].end.to_s
#
#    assert_nil vertices[6]
#

#    edges = @graph.edges.sort_by{ |edge| edge.start }
    # edges.each { |edge| p "###########"; p edge.id; p edge.source.id; p edge.target.id; p edge.start; p edge.end  }
#    assert_equal "2010-01-01 12:00:00 +0900", edges[0].start.to_s
#    assert_equal "2010-01-01 12:19:59 +0900", edges[0].end.to_s

#    assert_equal "2010-01-02 12:00:00 +0900", edges[1].start.to_s
#    assert_equal "2010-01-02 12:19:59 +0900", edges[1].end.to_s

#    assert_equal "2010-01-02 12:20:00 +0900", edges[2].start.to_s
#    assert_equal "2010-01-02 12:39:59 +0900", edges[2].end.to_s

#    assert_equal "2010-01-02 12:40:00 +0900", edges[3].start.to_s
#    assert_equal "2010-01-02 12:59:59 +0900", edges[3].end.to_s

#    assert_equal "2010-01-02 13:00:00 +0900", edges[4].start.to_s
#    assert_equal "2010-01-02 13:19:59 +0900", edges[4].end.to_s

#    assert_equal "2010-01-02 13:20:00 +0900", edges[5].start.to_s
#    assert_equal "2010-01-02 13:39:59 +0900", edges[5].end.to_s

#    assert_nil edges[6]

#    assert_equal 1, edges[0].weight
#    assert_equal 1, edges[1].weight
#    assert_equal 2, edges[2].weight
#    assert_equal 3, edges[3].weight
#    assert_equal 2, edges[4].weight
#    assert_equal 1, edges[5].weight
#  end

  def test_graph_dump_and_load
    #   2
    #  / \
    # 1   4
    #  \ /
    #   3
    vertex1 = Rgraphum::Vertex.new({id: 1, label: "vertex 1" })
    vertex2 = Rgraphum::Vertex.new({id: 2, label: "vertex 2" })
    vertex3 = Rgraphum::Vertex.new({id: 3, label: "vertex 3" })
    vertex4 = Rgraphum::Vertex.new({id: 4, label: "vertex 4" })
    vertices = [vertex1, vertex2, vertex3, vertex4]
    edges = [
      Rgraphum::Edge.new({source: vertex1, target: vertex2}),
      Rgraphum::Edge.new({source: vertex2, target: vertex4}),
      Rgraphum::Edge.new({source: vertex1, target: vertex3}),
      Rgraphum::Edge.new({source: vertex3, target: vertex4}),
    ]
    graph = Rgraphum::Graph.new(vertices: vertices, edges: edges)

    data = Marshal.dump(graph)
    graph_dash = Marshal.load(data)

    assert_equal graph, graph_dash
  end

  def test_graphs_dump_and_load
    #   2      2 - 5
    #  / \    /   /
    # 1   4  1   /
    #  \ /    \ /
    #   3      6
    vertex1 = Rgraphum::Vertex.new({id: 1, label: "vertex 1" })
    vertex2 = Rgraphum::Vertex.new({id: 2, label: "vertex 2" })
    vertex3 = Rgraphum::Vertex.new({id: 3, label: "vertex 3" })
    vertex4 = Rgraphum::Vertex.new({id: 4, label: "vertex 4" })
    vertex5 = Rgraphum::Vertex.new({id: 5, label: "vertex 5" })
    vertex6 = Rgraphum::Vertex.new({id: 6, label: "vertex 6" })

    vertices1 = [vertex1, vertex2, vertex3, vertex4]
    edges1 = [
      Rgraphum::Edge.new({source: vertex1, target: vertex2}),
      Rgraphum::Edge.new({source: vertex2, target: vertex4}),
      Rgraphum::Edge.new({source: vertex1, target: vertex3}),
      Rgraphum::Edge.new({source: vertex3, target: vertex4}),
    ]
    graph1 = Rgraphum::Graph.new(vertices: vertices1, edges: edges1)

    vertices2 = [vertex1, vertex2, vertex5, vertex6]
    edges2 = [
      Rgraphum::Edge.new({source: vertex1, target: vertex2}),
      Rgraphum::Edge.new({source: vertex2, target: vertex5}),
      Rgraphum::Edge.new({source: vertex1, target: vertex6}),
      Rgraphum::Edge.new({source: vertex6, target: vertex5}),
    ]
    graph2 = Rgraphum::Graph.new(vertices: vertices2, edges: edges2)

    graphs = [graph1, graph2, graph1]

    data = Marshal.dump(graphs)
    graphs_dash = Marshal.load(data)

    assert_equal graphs, graphs_dash
    refute_equal graphs_dash[0], graphs_dash[1]
    assert_equal graphs_dash[0], graphs_dash[2]
    assert_same  graphs_dash[0], graphs_dash[2]
    assert_same  graphs_dash[0].vertices[0], graphs_dash[2].vertices[0]
    assert_same  graphs_dash[0].edges[0],    graphs_dash[2].edges[0]

    assert_same  graphs_dash[0].edges[0], graphs_dash[0].vertices[0].edges[0]
  end

  def test_rgraphum_marshal
    vertex1 = Rgraphum::Vertex.new({id: 1, label: "vertex 1" })
    vertex2 = Rgraphum::Vertex.new({id: 2, label: "vertex 2" })
    vertices = [vertex1, vertex2]
    edges = [
      Rgraphum::Edge.new({source: vertex1, target: vertex2}),
    ]
    graph = Rgraphum::Graph.new(vertices: vertices, edges: edges)

    tempfile = Tempfile.new("graph.txt")
    graph.dump_to(tempfile.path)
    graph_dash = Rgraphum::Graph.load_from(tempfile.path)

    assert_equal graph, graph_dash
  end

  def test_simurate_1
    after_graph = @graph_a.simulate("BAModel", round: 1)
    assert_equal @graph_a.vertices.size + 1, after_graph.vertices.size 
    assert_equal @graph_a.edges.size    + 1, after_graph.edges.size 
  end

  def test_simurate_2
    after_graph = @graph_a.simulate("BAModel", round: 1, edge_size: 2)
    assert_equal @graph_a.vertices.size + 1, after_graph.vertices.size 
    assert_equal @graph_a.edges.size    + 2, after_graph.edges.size 
  end

  def test_simurate_3
    after_graph = @graph_a.simulate("BAModel", round: 2, edge_size: 2)
    assert_equal @graph_a.vertices.size + 2, after_graph.vertices.size 
    assert_equal @graph_a.edges.size    + 4, after_graph.edges.size 
  end

  private

  def make_test_graph
    @graph_a = Rgraphum::Graph.new
    @graph_a.vertices = [
      {:id => 1, :label => "hoge" },
      {:id => 2, :label => "huga" },
    ]
    vertices_a = @graph_a.vertices
    @graph_a.edges << { :id => 1, :source => vertices_a[0], :target => vertices_a[1], :weight => 1}
    @graph_a.edges << { :id => 2, :source => vertices_a[1], :target => vertices_a[0], :weight => 1}

    @graph_b = Rgraphum::Graph.new
    vertices_b = @graph_b.vertices = [
      {:id => 1, :label => "piyo" },
      {:id => 2, :label => "hogeratte" },
    ]
    vertices_b = @graph_b.vertices
    @graph_b.edges << { :id => 1, :source => vertices_b[0], :target => vertices_b[1], :weight => 2 }
    @graph_b.edges << { :id => 2, :source => vertices_b[1], :target => vertices_b[0], :weight => 2 }
  end
end
