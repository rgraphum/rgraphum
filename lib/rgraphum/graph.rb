# -*- coding: utf-8 -*-

class Rgraphum::Graph
  RGRAPHUM = Rgraphum

  include Rgraphum::Graph::Math
  include Rgraphum::Marshal
  include Rgraphum::Simulator
  include Rgraphum::Importer
  include Rgraphum::Parsers

  attr_accessor :label


  def self.build_from_adjacency_matrix( matrix, vertex_labels = [], options={} )
    options = { loop: false, limit: 0 }.merge(options)

    graph = new
    if vertex_labels.size == matrix.size
      vertex_labels.each do |label|
        v = graph.vertices.build(label:label)
      end
    else
      matrix.size.times do 
        graph.vertices.build
      end
    end

    matrix.each_with_index do | row,row_index|
      row.each_with_index do |weight,col_index|
        next if col_index == row_index and !options[:loop]
        
        if weight and weight >= options[:limit]
          graph.edges.build( {source:graph.vertices[row_index], target:graph.vertices[col_index],weight:weight} )
        end
      end
    end
    graph
  end

 
  # @param [Hash] options
  # @option options [Rgraphum::Vertices] :vertices   
  # @option options [Rgraphum::Edges]    :edges
  #
  def initialize(options={})
    @rgraphum_id = new_rgraphum_id
    @edge_counter_id = new_rgraphum_id

    @vertices = Rgraphum::Vertices.new
    if options[:vertices]
      self.vertices = options[:vertices]
    end
    @vertices.graph = self
    @vertices.each {|vertex| vertex.graph = self}


    @edges = Rgraphum::Edges.new
    if options[:edges]
      self.edges = options[:edges]
    end
    @edges.graph = self

    self
  end


  # reculc method
  def clear_cache
    @m = nil
    @m_with_weight = nil
    @adjacency_matrix = nil
    @minimum_distance_matrix = nil
  end

  # m is size of edges
  def m
    @m ||= @edges.size
  end

  # degree
  def degree
    self.m * 2
  end

  # m with weight
  def m_with_weight
    @m_with_weight ||= @edges.inject(0.0) { |sum, edge| sum + edge.weight }
  end

  # average degree
  def average_degree
    @average_degree ||= (2 * @m / @vertices.size)
  end

  def average_path_length
    raise NotImplementedError
  end

  # basic method
  def vertices
    @vertices
  end

  def vertices=(vertex_array)
    @vertices = @vertices.substitute(vertex_array) do |vertex|
      Rgraphum::Vertex(vertex)
    end
  end

  def edges
    @edges
  end

  def edges=(edge_array)
    edge_array.each do |edge|
      add_edge(edge)
    end
    @edges
  end

  def edge_new_id(id=nil,edge_rgraphum_id)
    element_new_id(id, edge_rgraphum_id, @edge_counter_id, @edges )
  end
 
  def vertex_new_id(id=nil,vertex_rgraphum_id)
    element_new_id(id, vertex_rgraphum_id, @vertex_counter_id, @vertices )
  end
 
  def element_new_id( id=nil, element_rgraphum_id, counter_id, elements )
    redis = Redis.current

    if id
      id = id.to_i
      return id unless element_id_exists?( elements.rgraphum_id,id )
    end

    id = redis.incr( counter_id )
    return id unless element_id_exists?( elements.rgraphum_id, id )
 
    redis.set( counter_id, elements.ids.max )
    id = redis.incr(counter_id)
  end

  def element_id_exists?(elements_rgraphum_id,id)
    redis = Redis.current
    redis.hexists(elements_rgraphum_id,id)
  end

  def add_edge(edge)
    edge = Rgraphum::Edge(edge)
    edge.graph = self

    raise ArgumentError, "Source vertex is required" unless edge.source
    raise ArgumentError, "Target vertex is required" unless edge.target
    
    edge.id = edge_new_id(edge.id,edge.rgraphum_id)

    edges.push_with_rgraphum_id edge
    edge.source.edges.push_with_rgraphum_id edge
    edge.source.out_edges.push_with_rgraphum_id edge

    edge.target.edges.push_with_rgraphum_id edge 
    edge.target.in_edges.push_with_rgraphum_id edge

    edge
  end

  def dup
    other = Marshal.load(Marshal.dump(self))
    other.vertices.each {|vertex| vertex.redis_dup }
    other.edges.each    {|edge|   edge.redis_dup   }
    other
  end

  def +(other)
    start_vertex_id = @vertices.id.max
    start_edge_id = @edges.id.max

    new_graph = Rgraphum::Graph.new
    (self.vertices + other.vertices).each do |vertex|
      v = new_graph.vertices.build(vertex.dup)
      v.edges = []
    end

    self.edges.each do |edge|
      edge_tmp = edge.dup
      new_graph.edges.build(edge_tmp)
    end

    other.edges.each do |edge|
      edge_tmp = edge.dup
      edge_tmp.source = edge.source.id + start_vertex_id
      edge_tmp.target = edge.target.id + start_vertex_id
      new_graph.edges.build(edge_tmp)
    end

    new_graph
  end

  def compact_with(method_name, graph=self, options ={})
    new_vertices = Rgraphum::Vertices.new
    new_vertices.graph = graph
    graph.vertices.each do |vertex|
      vertex.send(:words)
      same_vertex = new_vertices.find{ |v| v.send(method_name) == vertex.send(method_name) }
      unless same_vertex
        new_vertex = vertex.dup
        new_vertex.edges = Rgraphum::Edges.new
        new_vertices << new_vertex
      end
    end

    new_edges = Rgraphum::Edges.new
    graph.edges.each do |edge|
      source_label = edge.source.send(method_name)
      target_label = edge.target.send(method_name)
      edge.source = new_vertices.find{ |vertex| vertex.send(method_name) == source_label }
      edge.target = new_vertices.find{ |vertex| vertex.send(method_name) == target_label }

      same_edge = new_edges.find{ |e| e.source.equal?(edge.source) and e.source.equal?(edge.source) }
      if same_edge
        same_edge.weight += edge.weight
      else
        new_edges << edge
      end
    end

    graph.vertices = new_vertices
    graph.edges = new_edges
    graph
  end

  def ==(other)
    return false unless label    == other.label
    return false unless vertices == other.vertices
    return false unless edges    == other.edges
    true
  end
end
