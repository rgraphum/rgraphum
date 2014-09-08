require 'rgraphum'
require 'test_helper'

class RgraphumGraphBuilderTest < MiniTest::Unit::TestCase

  def test_build_from_from_adjacency_matrix
    labels =   ["hoge","huga","piyo","puyo"] 
    matrix = [ [  1.0 ,  0.7 ,  0.7 ,  nil ],
               [  nil ,  1.0 ,  nil ,  0.9 ],
               [  nil ,  0.8 ,  1.0 ,  0.3 ],
               [  nil ,  nil ,  nil ,  1.0 ] ]

    graph = Rgraphum::Graph.build_from_adjacency_matrix(matrix,labels)

    assert_equal    5,                     graph.edges.size

    assert_equal graph.edges[0].source.object_id, graph.vertices[0].object_id
    assert_equal graph.edges[0].target.object_id, graph.vertices[1].object_id
    assert_equal graph.edges[0].weight, 0.7
    
    assert_equal graph.edges[1].source.object_id, graph.vertices[0].object_id
    assert_equal graph.edges[1].target.object_id, graph.vertices[2].object_id
    assert_equal graph.edges[1].weight, 0.7

    assert_equal graph.edges[2].source.object_id, graph.vertices[1].object_id
    assert_equal graph.edges[2].target.object_id, graph.vertices[3].object_id
    assert_equal graph.edges[2].weight, 0.9

    assert_equal graph.edges[3].source.object_id, graph.vertices[2].object_id
    assert_equal graph.edges[3].target.object_id, graph.vertices[1].object_id
    assert_equal graph.edges[3].weight, 0.8

    assert_equal graph.edges[4].source.object_id, graph.vertices[2].object_id
    assert_equal graph.edges[4].target.object_id, graph.vertices[3].object_id
    assert_equal graph.edges[4].weight, 0.3

    graph = Rgraphum::Graph.build_from_adjacency_matrix(matrix,labels,{:loop=>true,limit:0.8})

    assert_equal graph.edges[0].source.object_id, graph.vertices[0].object_id
    assert_equal graph.edges[0].target.object_id, graph.vertices[0].object_id
    assert_equal graph.edges[0].weight, 1.0

    assert_equal graph.edges[1].source.object_id, graph.vertices[1].object_id
    assert_equal graph.edges[1].target.object_id, graph.vertices[1].object_id
    assert_equal graph.edges[1].weight, 1.0

    assert_equal graph.edges[2].source.object_id, graph.vertices[1].object_id
    assert_equal graph.edges[2].target.object_id, graph.vertices[3].object_id
    assert_equal graph.edges[2].weight, 0.9
    
    assert_equal graph.edges[3].source.object_id, graph.vertices[2].object_id
    assert_equal graph.edges[3].target.object_id, graph.vertices[1].object_id
    assert_equal graph.edges[3].weight, 0.8

    assert_equal graph.edges[4].source.object_id, graph.vertices[2].object_id
    assert_equal graph.edges[4].target.object_id, graph.vertices[2].object_id
    assert_equal graph.edges[4].weight, 1.0

    assert_equal graph.edges[5].source.object_id, graph.vertices[3].object_id
    assert_equal graph.edges[5].target.object_id, graph.vertices[3].object_id
    assert_equal graph.edges[5].weight, 1.0

  end

  def test_simirality_graph_builder
    # no data make not rise error but return builder 
    graph_builder = GraphBuilder.new("simirarity_graph")

    # count graph
    data = [ ["hoge","x",1.0],
             ["hoge","y",1.0],
             ["hoge","z",0.0],
             ["huga","x",1.0],
             ["huga","y",0.0],
             ["huga","z",1.0],
             ["piyo","x",0.0],
             ["piyo","y",1.0],
             ["piyo","z",1.0] ]

    graph = GraphBuilder.new.similarity_graph(data)

    except_data = [ { source:"hoge", target:"huga", weight:0.5},
                    { source:"hoge", target:"piyo", weight:0.5},
                    { source:"huga", target:"piyo", weight:0.5} ]


    except_data.zip(graph.edges) do |pair|
    end

  end
end
