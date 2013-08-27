# -*- coding: utf-8 -*-
class Rgraphum::Graph
end

module Rgraphum::Graph::Math
  require_relative 'math/dijkstra'
  require_relative 'math/clustering_coefficient'
  require_relative 'math/degree_distribution'
  require_relative 'math/community_detection'

  def self.included(base)
    # base.extend ClassMethods
    base.send :include, Rgraphum::Graph::Math::Dijkstra
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

  private

  def community_by_id(community_id)
    community_id = community_id.id if community_id.is_a?(Rgraphum::Community)
    vertices = @vertices.find_all { |vertex| vertex.community_id == community_id }
    Rgraphum::Community.new(id: community_id, graph: self, vertices: vertices)
  end

end
