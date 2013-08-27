# -*- coding: utf-8 -*-

module Rgraphum::Graph::Math::ClusteringCoefficient
  def self.included(base)
    base.extend ClassMethods
    base::RGRAPHUM::Vertex.send :include, VertexMethods
  end

  # Global clustering coefficient
  #
  # Returns clustering coefficient in Rational
  #
  def clustering_coefficient
    n = vertices.size
    # vertices.inject(0) { |cc, vertex|
    #   cc + (vertex.clustering_coefficient / n)
    # }
    sum_of_local_clustering_coefficient = vertices.inject(0) { |cc, vertex|
      cc + (vertex.clustering_coefficient)
    }
    sum_of_local_clustering_coefficient / n
  end

  module ClassMethods
  end

  module VertexMethods
    # Local clustering coefficient
    #
    # <pre>
    # open triplet    closed triplet
    #  V1   V2         V1 - V2
    #   \   /           \   /
    #    V3              V3
    # </pre>
    #
    def clustering_coefficient
      ajacency_vertices = both
      return Rational(0) if ajacency_vertices.size < 2
      num_open_triplets, num_close_triplets = 0, 0
      ajacency_vertices.combination(2) do |(v1, v2)|
        va, vb = v1, v2
        va, vb = v2, v1 if v1.edges.size > v2.edges.size
        if va.edges.any? { |e| e.bothV.include?(vb) }
          num_close_triplets += 1
        else
          num_open_triplets += 1
        end
      end
      Rational(num_close_triplets, num_open_triplets + num_close_triplets)
    end
  end
end
