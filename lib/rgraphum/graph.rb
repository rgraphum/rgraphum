# -*- coding: utf-8 -*-

# FIXME some 'edge.source's are edge.source.id
# FIXME some 'edge.target's are edge.target.id

class Rgraphum::Graph
  RGRAPHUM = Rgraphum

  include Rgraphum::Graph::Math
  include Rgraphum::Graph::Gremlin
  include Rgraphum::Marshal
  include Rgraphum::Simulator
  include Rgraphum::Importer
  include Rgraphum::Parsers

  attr_accessor :aspect
  attr_accessor :label

  class << self

    def build_from_adjacency_matrix( matrix, vertex_labels = [], options={} )
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
p row_index
            graph.edges.build( {source:graph.vertices[row_index], target:graph.vertices[col_index],weight:weight} )
          end
        end
      end
      graph
    end

  end
 
  # @param [Hash] options
  # @option options [Rgraphum::Vertices] :vertices   
  # @option options [Rgraphum::Edges]    :edges
  #
  def initialize(options={})
    @vertices = Rgraphum::Vertices.new
    if options[:vertices]
      self.vertices = options[:vertices]
    else
      @vertices.graph = self
    end

    @edges = Rgraphum::Edges.new
    if options[:edges]
      @edges.graph = self
      self.edges = options[:edges]
    else
      @edges.graph = self
    end

    @aspect = "real"
    self
  end


  # reculc method
  def clear_cache
    @m = nil
    @m_with_weight = nil
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
    @edges = @edges.substitute(edge_array) do |edge|
      Rgraphum::Edge(edge)
    end
  end

  # to_real mean edge has vertex pointer
  def real_aspect!
    return self if @aspect == "real"

    edges.each do |edge|
      edge.source = @vertices.find_by_id(edge.source) # FIXME
      edge.target = @vertices.find_by_id(edge.target) # FIXME
    end

    @aspect = "real"
    self
  end

  # to_id mean edge has vertex id
  def id_aspect!
    return self if @aspect == "id"

    edges.each do |edge|
      edge.source = edge.source.id
      edge.target = edge.target.id
    end

    @aspect = "id"
    self
  end


  def dup
    new_graph = Rgraphum::Graph.new

    @vertices.each do |vertex|
      new_vertex = vertex.dup
      new_vertex.edges = Rgraphum::Edges.new
      new_graph.vertices << new_vertex
    end

    @edges.each do |edge|
      new_graph.edges << edge.dup
    end

    new_graph
  end

  def +(other)
    new_graph = Rgraphum::Graph.new
    start_vertex_id = @vertices.id.max
    start_edge_id = @edges.id.max

    other_dup = other.dup
    other_dup.vertices.each do | vertex |
      vertex.id = vertex.id + start_vertex_id
    end
    other_dup.edges.each do |edge|
      edge.id = edge.id + start_edge_id
    end

    new_graph.vertices = self.dup.vertices + other_dup.vertices
    new_graph.edges = self.dup.edges + other_dup.edges

    new_graph
  end

  def compact_with_label(options={})
    compact_with(:label, self, options)
  end

  def marge_with_label(target)
    new_graph = self + target
    new_graph.compact_with_label
  end

  def divide_by_time(interval=20)
    @vertices.divide_by_time(interval)
    @edges.divide_by_time(interval)

    new_edges = Rgraphum::Edges.new
    new_edges.graph = self
    @edges.each do |edge|
      conditions = { source: edge.source, target: edge.target, start: edge.start }
      same_edge = new_edges.where(conditions).first
      if same_edge
        same_edge.weight += edge.weight
      else
        new_edges << edge
      end
    end
    self.edges = new_edges
  end

  def compact_with(method_name, graph=self, options ={})
    new_vertices = Rgraphum::Vertices.new
    new_vertices.graph = graph
    graph.vertices.each do |vertex|
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
    return false unless aspect   == other.aspect
    return false unless label    == other.label
    return false unless vertices == other.vertices
    return false unless edges    == other.edges
    true
  end
end
