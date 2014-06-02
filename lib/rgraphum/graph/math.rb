# -*- coding: utf-8 -*-
class Rgraphum::Graph
end

module Rgraphum::Graph::Math
  require_relative 'math/distance_calculator'
  require_relative 'math/clustering_coefficient'
  require_relative 'math/degree_distribution'
  require_relative 'math/community_detection'

  def self.included(base)
    # base.extend ClassMethods
    base.send :include, Rgraphum::Graph::Math::ClusteringCoefficient
  end

  def modularity
    CommunityDetection.new(self).modularity
  end

  def communities
    existing_community_ids = {}
    communities = []
    @vertices.each do |vertex|
      next if existing_community_ids.key?(vertex.community_id)
      community = community_by_id(vertex.community_id)
      communities << community
      existing_community_ids[community.id] = true
    end
    Rgraphum::Communities(communities)
  end

  def power_low_rand(max,min,exponent)
    ( (max^exponent-min^exponent)*rand() + min^exponent )^( 1.0/exponent )
  end

  def minimum_distance_matrix
    return @minimum_distance_matrix if @minimum_distance_matrix
    @minimum_distance_matrix = DistanceCalculator.new.minimum_distance_matrix(self) 
  end

  def average_distance
    distance_array = self.minimum_distance_matrix.flatten.compact
    ( distance_array.inject(&:+) / distance_array.size.to_f )
  end

  def adjacency_matrix
    return @adjacency_matrix if @adjacency_matrix
    ids = self.vertices.id
    @adjacency_matrix = Array.new(ids.size){ Array.new(ids.size) }
    self.vertices.each do |source_vertex|
      source_vertex.outE.each do |edge|
        target_vertex = edge.target
        i = ids.index(target_vertex.id)
        j = ids.index(source_vertex.id)
        @adjacency_matrix[i][j] = edge.weight
      end
    end
    @adjacency_matrix
  end

  def adjacency_matrix_index
    self.vertices.id
  end

  def minimum_route(a,b)
    []
  end

  def path
    []
  end

  private

  def community_by_id(community_id)
    community_id = community_id.id if community_id.is_a?(Rgraphum::Community)
    vertices = @vertices.find_all { |vertex| vertex.community_id == community_id }
    Rgraphum::Community.new(id: community_id, graph: self, vertices: vertices)
  end

end
