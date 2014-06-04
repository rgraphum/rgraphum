# -*- coding: utf-8 -*-

module Rgraphum::Graph::Math

  class DistanceCalculator
    def minimum_distance_matrix(graph)
      @minimum_distance_matrix = Marshal.load(Marshal.dump(graph.adjacency_matrix))
      n = @minimum_distance_matrix.size

      # pre selection
      i_array = []
      j_array = []
      k_array = []
      graph.vertices.each_with_index do |vertex,index|
        in_edges  = vertex.in_edges
        out_edges = vertex.out_edges

        i_array << index unless out_edges.empty?
        j_array << index unless in_edges.empty?
        next if out_edges.empty? or in_edges.empty?
        next k_array << index if out_edges.size > 1 and in_edges.size > 1
        
        unless out_edges[0].target == in_edges[0].source
          k_array << index
        end
      end

      k_array.each do |k|
        i_array.each do |i|
          j_array.each do |j|
            next if i == j
            next unless i_k = @minimum_distance_matrix[i][k] and k_j = @minimum_distance_matrix[k][j]
            i_j = @minimum_distance_matrix[i][j]
            if !i_j or i_j > i_k + k_j
              @minimum_distance_matrix[i][j] = i_k + k_j
            end
          end
        end
      end
      @minimum_distance_matrix
    end

    def average_distance(graph)
      minimun_distance_matrix.each do |row|
      end
    end

  end
end
