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
    vertex_column = data.transpose[0]
    value_column = data.transpose[1]

    # value_be_check
    count_flag = true if data[0].size == 2

    # make label and index hash
    vertelabels = vertex_labels.uniq
    value_labels  = value_labels.uniq

    value_label_index_hash = {}
    value_labels.each_with_index{|value_label,i| value_label_index_hash[value_lavel] = i }

    vertex_label_index_hash = {}
    vertex_labels.each_with_index{|vertex_label,i| vertex_label_index_hash[vertex_lavel] = i }

    puts "size vertex:      #{vetex_label.size}"
    puts "size vector_size: #{value_label.size}"

    vertex_value_matrix = Array.new(vertex_labels.size).map!{ |i| Array.new( value_labels.size, 0.0 ) }
    count_array = Array.new(vertex_labels.size).map!{ |i| Array.new( value_labels.size, 0   ) }

    # make item_user_matrix
    # examle:
    #           valueA valueB
    # vertexA [ [   1      2   ],
    # vertexB   [   0      1   ] ]

    data.each_with_index do  |vertex_label,value_label,value,row_i|
      j = vertex_label_index_hash[vertex_label]
      i = value_label_index_hash[value_label]

      if count_flg
        value = 1
      else
        next p row_i.to_s + ":no value data" unless value
      end

      vertex_value_matrix[ vertex_label_index_hash[vertex_label] ] [ value_label_index_hash[value_label] ] ||=0
      vertex_value_matrix[ vertex_label_index_hash[vertex_label] ] [ value_label_index_hash[value_label] ] += value
    end

    ############################################
    # del with vale size all zero value
    t_vertex_value_matrix = vertex_value_matrix.transpose
    t_vertex_value_matrix.delete_if do |values|
      flg = true
      values.each do |value|
        break flg = false if value > 0.0
      end
      flg
    end
    vertex_value_matrix = t_vertex_value_matrix.transpose

    # del with item size
    i = 0
    item_customer_matrix.delete_if do |item|
      if item.inject(:+) < 30
        item_label.delete_at(i)
        next true
      end
      i = i + 1
      false
    end

    # sample
    sample_index = (0...item_customer_matrix.size).to_a.sample(10000)
    item_label = sample_index.map { |index| item_label[index] }.compact
    item_customer_matrix = sample_index.map { |index| item_customer_matrix[index] }.compact

    # del with customer zero
    t_item_customer_matrix = item_customer_matrix.transpose
    t_item_customer_matrix.delete_if do |customer|
      customer.inject(:+) == 0
    end
    item_customer_matrix = t_item_customer_matrix.transpose

##############################################################################
p   "x sise"
p   item_customer_matrix.size   
p   "y size"
p   item_customer_matrix[0].size
   
    #tf-idf
    p "tf-idf"
    tf_idf = TfIdf.new
    tf_idf_matrix = tf_idf.tf_idf(item_customer_matrix) 
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
    graph = Rgraphum::Graph.build_from_adjacency_matrix(csm_matrix,item_label,options)

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
