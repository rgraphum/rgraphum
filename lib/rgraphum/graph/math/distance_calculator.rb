# -*- coding: utf-8 -*-

module Rgraphum::Graph::Math

  class DistanceCalculator
    def minimum_distance_matrix(graph)
      @minimum_distance_matrix = Marshal.load(Marshal.dump(graph.adjacency_matrix))
      n = @minimum_distance_matrix.size

      n.times.each do |k|
        n.times.each do |i|
          n.times.each do |j|
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
