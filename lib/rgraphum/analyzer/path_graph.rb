# -*- coding: utf-8 -*-

class Rgraphum::Analyzer::PathGraph

  class  << self
    def build(graph_or_vertex)
      builder = self.new
      path_graphs = []
      if graph_or_vertex.class == Rgraphum::Graph
        builder.start_root_vertices(graph_or_vertex).each do |vertex|
          path_graphs << builder.make_path_graph(vertex)
        end
        return path_graphs
      elsif graph_or_vertex.class == Rgraphum::Graph::Vertex 
        return builder.make_path_graph(vertex)
      end
    end
  end
  
  def start_root_vertices(target_graph=@graph)
    target_graph.vertices.find_all{ |vertex| vertex.in_edges.empty? and !vertex.out_edges.empty? }
  end

  def make_path_graph(vertex)
    pre_graph  = vertex.graph.dup
    vertex     = pre_graph.vertices.find_by_id(vertex.id)
    graph = Rgraphum::Graph.new
    
    @d ||= Dijkstra.new 
    target_paths = @d.path_one_to_n(vertex)
    
    target_paths.each do |target,path|
      path.each_cons(2) do |a,b| 
        edge = a.out_edges.where( :target => b ).first
      
        graph.vertices.build(a) unless graph.vertices.include?(a)
        graph.vertices.build(b) unless graph.vertices.include?(b)
        next unless edge
        graph.edges.build(edge) unless graph.edges.include?(edge)

      end
    end
    graph
  end

end
