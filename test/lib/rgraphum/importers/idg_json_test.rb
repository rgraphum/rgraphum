# -*- coding: utf-8 -*-

require 'rgraphum'
require 'test_helper'

class RgraphumImporterIdgJsonTest < MiniTest::Unit::TestCase
  def test_build_vertex
    vertices_json_str = <<-EOT
{
  "result": [{
      "@type": "d", "@rid": "#-2:0", "@version": 0, 
"rid": "#6:0", 
"x": 999.99999, 
"y": 999.99999, 
"r": 99.999999, 
"rgb": 99999999, 
"screen_name": "person_1", 
"actor_type": 0, 
"c_id": 0, 
"c_is_parent": 0, 
"c_r": 99.999999, 
"c_rgb": 9999999, 
  "@fieldTypes": "x=f,y=f,r=f,c_r=f"
    }
  ]
}
    EOT

    graph = Rgraphum::Graph.build(format: :idg_json, vertices: vertices_json_str)
    assert_equal 1, graph.vertices.size
    assert_equal 0, graph.edges.size

    vertex = graph.vertices[0]
    assert_equal "person_1", vertex.label
  end

  def test_build_vertices
    vertices_json_str = <<-EOT
{
  "result": [{
      "@type": "d", "@rid": "#-2:0", "@version": 0, 
"rid": "#6:0", 
"x": 999.99999, 
"y": 999.99999, 
"r": 99.999999, 
"rgb": 99999999, 
"screen_name": "person_a", 
"actor_type": 0, 
"c_id": 0, 
"c_is_parent": 0, 
"c_r": 99.999999, 
"c_rgb": 9999999, 
  "@fieldTypes": "x=f,y=f,r=f,c_r=f"
    }, {
      "@type": "d", "@rid": "#-2:1", "@version": 0, 
"rid": "#6:1", 
"x": 999.99999, 
"y": 999.99999, 
"r": 99.99999, 
"rgb": 99999999, 
"screen_name": "person_b", 
"actor_type": 0, 
"c_id": 0, 
"c_is_parent": 1, 
"c_r": 99.999999, 
"c_rgb": 9999999, 
  "@fieldTypes": "x=f,y=f,r=f,c_r=f"
    }, {
      "@type": "d", "@rid": "#-2:2", "@version": 0, 
"rid": "#6:2", 
"x": 999.99999, 
"y": 999.99999, 
"r": 99.999999, 
"rgb": 99999999, 
"screen_name": "person_c", 
"actor_type": 0, 
"c_id": 0, 
"c_is_parent": 0, 
"c_r": 99.999999, 
"c_rgb": 9999999, 
  "@fieldTypes": "x=f,y=f,r=f,c_r=f"
    }
  ]
}
    EOT

    graph = Rgraphum::Graph.build(format: :idg_json, vertices: vertices_json_str)
    assert_equal 3, graph.vertices.size
    assert_equal 0, graph.edges.size

    assert_equal "person_a", graph.vertices[0].label
    assert_equal "person_b", graph.vertices[1].label
    assert_equal "person_c", graph.vertices[2].label
  end

  def test_build_vertices_and_edges
    vertices_json_str = <<-EOT
{
  "result": [{
      "@type": "d", "@rid": "#-2:0", "@version": 0, 
"rid": "#6:0", 
"x": 999.99999, 
"y": 999.99999, 
"r": 99.999999, 
"rgb": 99999999, 
"screen_name": "person_a", 
"actor_type": 0, 
"c_id": 0, 
"c_is_parent": 0, 
"c_r": 99.999999, 
"c_rgb": 9999999, 
  "@fieldTypes": "x=f,y=f,r=f,c_r=f"
    }, {
      "@type": "d", "@rid": "#-2:1", "@version": 0, 
"rid": "#6:1", 
"x": 999.99999, 
"y": 999.99999, 
"r": 99.99999, 
"rgb": 99999999, 
"screen_name": "person_b", 
"actor_type": 0, 
"c_id": 0, 
"c_is_parent": 1, 
"c_r": 99.999999, 
"c_rgb": 9999999, 
  "@fieldTypes": "x=f,y=f,r=f,c_r=f"
    }, {
      "@type": "d", "@rid": "#-2:2", "@version": 0, 
"rid": "#6:2", 
"x": 999.99999, 
"y": 999.99999, 
"r": 99.999999, 
"rgb": 99999999, 
"screen_name": "person_c", 
"actor_type": 0, 
"c_id": 0, 
"c_is_parent": 0, 
"c_r": 99.999999, 
"c_rgb": 9999999, 
  "@fieldTypes": "x=f,y=f,r=f,c_r=f"
    }
  ]
}
    EOT

    edges_json_str = <<-EOT
{
  "result": [{
      "@type": "d", "@rid": "#-2:0", "@version": 0, 
"in": "#6:0", 
"out": "#6:1", 
"statusIds": "999999999999999999", 
"weight": 1.0, 
"created_at": 1373554121, 
  "@fieldTypes": "weight=f,created_at=l"
    }, {
      "@type": "d", "@rid": "#-2:1", "@version": 0, 
"in": "#6:2", 
"out": "#6:1", 
"statusIds": "999999999999999999", 
"weight": 1.0, 
"created_at": 1373553637, 
  "@fieldTypes": "weight=f,created_at=l"
    }
  ]
}
    EOT

#    Rgraphum::Edge.instance_eval {
#      field :created_at # FIXME
#    }

    graph = Rgraphum::Graph.build(format: :idg_json, vertices: vertices_json_str, edges: edges_json_str)
    assert_equal 3, graph.vertices.size
    assert_equal 2, graph.edges.size

    assert_equal "person_a", graph.vertices[0].label
    assert_equal "person_b", graph.vertices[1].label
    assert_equal "person_c", graph.vertices[2].label

    assert_equal "person_a", graph.edges[0].source.label
    assert_equal "person_b", graph.edges[0].target.label
    assert_equal "2013-07-11 23:48:41 JST", graph.edges[0].created_at.strftime("%Y-%m-%d %H:%M:%S %Z")

    assert_equal "person_c", graph.edges[1].source.label
    assert_equal "person_b", graph.edges[1].target.label
    assert_equal "2013-07-11 23:40:37 JST", graph.edges[1].created_at.strftime("%Y-%m-%d %H:%M:%S %Z")
  end

  def test_load_vertices_and_edges
    v_path = File.join(File.dirname(__FILE__), "idg_json_vertices.json")
    e_path = File.join(File.dirname(__FILE__), "idg_json_edges.json")

    graph = Rgraphum::Graph.load(format: :idg_json, vertices: v_path, edges: e_path)
    assert_equal 3, graph.vertices.size
    assert_equal 2, graph.edges.size

    assert_equal "person_a", graph.vertices[0].label
    assert_equal "person_b", graph.vertices[1].label
    assert_equal "person_c", graph.vertices[2].label

    assert_equal "person_a", graph.edges[0].source.label
    assert_equal "person_b", graph.edges[0].target.label
    assert_equal "person_c", graph.edges[1].source.label
    assert_equal "person_b", graph.edges[1].target.label
  end
end
