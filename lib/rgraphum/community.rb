# -*- coding: utf-8 -*-

def Rgraphum::Community(hash_or_community)
  if hash_or_community.instance_of?(Rgraphum::Community)
    hash_or_community
  else
    Rgraphum::Community.new(hash_or_community)
  end
end

class Rgraphum::Community
  attr_reader :graph
  attr_reader :id
  attr_reader :vertices

  def initialize(options={})
    @id       = options[:id]
    @graph    = options[:graph]
    @vertices = []

    if options[:vertices]
      options[:vertices].each do |vertex|
        add_vertex vertex
      end
    end
  end

  def add_vertex(vertex)
    @vertices << vertex
  end

  def inter_edges
    return @inter_edges if @inter_edges
    @inter_edges = []
    @vertices.combination(2) do |vertex_a, vertex_b|
      @inter_edges += (vertex_a.edges & vertex_b.edges)
    end
    @inter_edges
  end

  def outer_edges
    @outer_edges ||= edges - inter_edges
  end

  def edges
    @edges ||= Rgraphum::Edges.new(@vertices.map(&:edges).flatten.uniq)
  end

  def edges_from(community)
    edges & community.edges || []
  end

  def degree_weight
    @vertices.inject(0) { |sum, vertex| sum + vertex.degree_weight }
  end

  def sigma_in
    @sigma_in ||= inter_edges.inject(0) { |sum, edge|
      sum + edge.weight
    }
  end

  def update
    @inter_edges = nil
    @outer_edges = nil
    @edges = nil
    @sigma_tot = nil
    @sigma_in = nil
  end

  def neighborhood?
    raise NotImplementedError
  end 
  
  def merge(other_community)
    other_community.vertices.each do |vertex|
      vertex.community_id = self.id
      @vertices << vertex
    end
    self.update
  end

  def to_graph
    Rgraphum::Graph.new(vertices: vertices, edges: inter_edges)
  end
end
