# -*- mode: ruby coding: utf-8 -*-

require 'time'

require_relative 'graph_builder/vertex_value_matrix'
require_relative 'graph_builder/tf_idf'
require_relative 'graph_builder/cosine_similarity_matrix'

class GraphBuilder
  TEMPLATE_NAME_METHOD_SYN_MAP = {
    "imilaritygraph"  => :similarity_graph,
    "flowgraph"       => :flow_graph
  }
  

  def initialize(graph_template_syn = nil,data=[])
    return self unless graph_template_syn
    if data == []
      puts "no data"
      return self
    end

    template_name = graph_template_name.dup.downcase.gsub(/[^a-z0-9]/, "")
    method_syn = TEMPLATE_NAME_METHOD_SYN_MAP[template_name]
    raise ArgumentError, "Graph template not found: '#{template_name}'" unless method_syn
    self.send( method_syn, data)    
  end
  
  # data = [vertex_label,vertex_label] or [vertex_label,value_label,value]
  def similarity_graph(data,options={})

    vertex_value_matrix,labels = VertexValueMatrix.build(data)
p labels
p vertex_value_matrix
   
    #tf-idf
    p "tf-idf"
    tf_idf = TfIdf.new
    tf_idf_matrix = tf_idf.tf_idf(vertex_value_matrix) 
    p Time.now

    # cosine sim
    p "cosine sim"
    csm = CosineSimilarityMatrix.new
    csm_matrix = csm.similarity(tf_idf_matrix)
    p Time.now


    # downer traiangle matrix to 0
    csm_matrix.each_with_index do |row,row_i|
      row.each_with_index do |item,col_i|
        item = 0 if row_i > col_i
      end
    end    

    # make graph
    p "make graph"
    graph = Rgraphum::Graph.build_from_adjacency_matrix(csm_matrix,labels,options)

  end

  def flow_graph(data,options={})
    user_history_hash = {}
    data.each do |raw|
      user = raw[0]
      action = raw[1]
      user_history_hash[user] ||= []
      user_history_hash[user] << action 
    end

    graph = Rgraphum::Graph.new
    vertices = graph.vertices
    edges = graph.edges
 
    find_vertex_or_build = Proc.new do |label|
      vertices.where(label:label).first || vertices.build(label:label)
    end
 
    find_edge_or_build = Proc.new do  |s_v,t_v|
      if found_edge = edges.where(source: s_v, target: t_v).first
        found_edge
      else
        edges.build(source: s_v,target: t_v)
      end
    end
 
    user_history_hash.each do |user,history|
      next if history.size < 1

      pre_site_vertex = find_vertex_or_build.call("start")
      history.each do |page_label|
        target_v = find_vertex_or_build.call(page_label)
        edge = find_edge_or_build.call(pre_site_vertex,target_v)
        edge.weight ||= 0
        edge.weight += 1
        pre_site_vertex = target_v
      end
      end_vertex = find_vertex_or_build.call("end")
      end_edge = find_edge_or_build.call(pre_site_vertex,end_vertex)
      end_edge.weight ||= 0
      end_edge.weight += 1
    end

    graph
  end

end
