# -*- coding: utf-8 -*-

module Rgraphum::Graph::Math

  class DistanceCalculator

    def minimum_distance_matrix(graph)
      vertex_id_array = graph.vertices.id
      minimum_distance_matrix = Array.new(vertex_id_array.size){ Array.new(vertex_id_array.size) }

      d = Dijkstra.new
      vertices = graph.vertices.sort do |a,b| 
        seed_a = a.in_edges.size.to_f / ( a.edges.size ** 2 + 1 )
        seed_b = b.in_edges.size.to_f / ( b.edges.size ** 2 + 1 )
        seed_a <=> seed_b
      end

      vertices.each_with_index do |source,i|
        vertex_distance_hash = d.distance_one_to_n(source)
        vertex_distance_hash.each do |target,distance|
          s_id = vertex_id_array.index(source.id)
          t_id = vertex_id_array.index(target.id)

          minimum_distance_matrix[s_id][t_id] = distance
        end
      end

      minimum_distance_matrix
    end

    def average_distance(graph)
      minimun_distance_matrix.each do |row|
      end
    end

  end
end
