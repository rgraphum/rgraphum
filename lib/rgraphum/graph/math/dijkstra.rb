#module Rgraphum::Graph::Math::Hoge
#  def self.included(base)
#    base.extend ClassMethods
#  end
#
#  def adjacency_matrix
#    self.class.adjacency_matrix(self)
#  end
#
#end

class Dijkstra
 
  # Find shortest route from start to end
  #
  # Returns array of vertices
  #
  def dijkstra(graph, start_vertex, end_vertex)
    details = dijkstra_details(graph, start_vertex, end_vertex)
    routes = details[:routes]

    return [] if routes.nil? || routes.empty?
    routes[0][:vertices]
  end

  # Find shortest routes from start to end
  #
  # Returns routes
  #
  def dijkstra_details(graph, start_vertex, end_vertex)
    return {} if start_vertex.id == end_vertex.id

    end_id = end_vertex.id
    size = graph.vertices.size

    shortest_map = Array.new(size, Float::INFINITY)
    adjacency_matrix = adjacency_matrix(graph)

    routes = []

    start_index = graph.vertices.index(start_vertex)
    weights = adjacency_matrix[start_index]
    weights.each_with_index do |weight, i|
      next unless weight
      shortest_map[i] = weight

      vertex = graph.vertices[i]
      routes << {
        id: vertex.id,
        index: i,
        vertices: [start_vertex, vertex],
        weights: [weight],
        total_weight: weight,
        ended: vertex.id == end_id,
      }
    end

    loop do
      shortest_route = routes.min_by { |route|
        route[:ended] ? Float::INFINITY : route[:total_weight]
        }
        break if !shortest_route || shortest_route[:ended]

        routes.delete shortest_route
        weights = adjacency_matrix[shortest_route[:index]]
        weights.each_with_index do |weight, i|
          next unless weight
          vertex = graph.vertices[i]
          next if shortest_route[:vertices].include?(vertex)

          total_weight = shortest_route[:total_weight] + weight
          next if shortest_map[i] < total_weight
          shortest_map[i] = total_weight

          routes << {
            id: vertex.id,
            index: i,
            vertices: shortest_route[:vertices] + [vertex],
            weights: shortest_route[:weights] + [weight],
            total_weight: shortest_route[:total_weight] + weight,
            ended: vertex.id == end_id,
          }
        end

        remove_long_routes routes
      end

      {
        graph: graph,
        start_vertex: start_vertex,
        end_vertex: end_vertex,
        routes: routes,
        shortest_map: shortest_map,
        adjacency_matrix: adjacency_matrix,
      }
    end

#    # 隣接行列 Adjacency matrix
#    def adjacency_matrix(graph)
#      return @adjacency_matrix if @adjacency_matrix
#      ids = graph.vertices.map(&:id)
#      id_index_map = Hash[*ids.map.with_index { |id, i| [id, i] }.flatten]
#      size = graph.vertices.size
#      adjacency_matrix = (0...size).map { Array.new(size) }
#
#      graph.edges.each do |e|
#        i = id_index_map[e.source.id]
#        j = id_index_map[e.target.id]
#        adjacency_matrix[i][j] = e.weight
#        adjacency_matrix[j][i] = e.weight # FIXME
#      end
#
#      @adjacency_matrix = adjacency_matrix
#    end

    def average_distance_with_minimum_distance_matrix(graph, &block)
      minimum_distance_matrix = yield
      n = minimum_distance_matrix.size
      total_minimum_distane = 0
      (0...n).each do |i|
        ((i+1)...n).each do |j|
          total_minimum_distane += minimum_distance_matrix[i][j]
        end
      end
      Rational(total_minimum_distane, Rational(n * (n-1), 2))
    end

    def average_distance(graph)
      average_distance_with_minimum_distance_matrix(graph) {
        minimum_distance_matrix(graph)
      }
    end

    def quick_average_distance(graph)
      average_distance_with_minimum_distance_matrix(graph) {
        quick_minimum_distance_matrix(graph)
      }
    end

    def minimum_distance_matrix(graph)
      size = graph.vertices.size
      distance_matrix = (0...size).map { Array.new(size) }

      (0...size).each do |i|
        (i...size).each do |j|
          if i == j
            distance = 0
          else
            v1, v2 = graph.vertices[i], graph.vertices[j]
            details = dijkstra_details(graph, v1, v2)
            weights = details[:routes][0][:weights] rescue []
            if weights.empty?
              distance = nil
            else
              distance = weights.inject(0, &:+)
            end
          end
          distance_matrix[i][j] = distance
        end
      end

      (0...(size-1)).each do |i|
        ((i+1)...size).each do |j|
          distance_matrix[j][i] = distance_matrix[i][j]
        end
      end
      distance_matrix
    end

    def quick_minimum_distance_matrix(graph)
      size = graph.vertices.size
      distance_matrix = (0...size).map { Array.new(size) }

      remaining_paths = {}
      (0...(size-1)).each do |i|
        ((i+1)...size).each do |j|
          remaining_paths[[i, j]] = true
        end
      end

      until remaining_paths.empty?
        (i, j), _ = remaining_paths.shift
        v1, v2 = graph.vertices[i], graph.vertices[j]
        
        details = dijkstra_details(graph, v1, v2)
        weights = details[:routes][0][:weights] rescue []
        if weights.empty?
          distance_matrix[i][j] = nil
        else
          route_vertices = details[:routes][0][:vertices]
          route_vertices_size = route_vertices.size

          (0...(route_vertices_size-1)).each do |k|
            ((k+1)...route_vertices_size).each do |l|
              m = graph.vertices.index(route_vertices[k])
              n = graph.vertices.index(route_vertices[l])
              m, n = n, m if m > n
              unless distance_matrix[m][n]
                distance_matrix[m][n] = weights[k..l].inject(0, &:+)
                remaining_paths.delete [m, n]
              end
            end
          end
        end
      end

      (0...size).each do |i|
        distance_matrix[i][i] = 0
      end
      (0...(size-1)).each do |i|
        ((i+1)...size).each do |j|
          distance_matrix[j][i] = distance_matrix[i][j]
        end
      end

      distance_matrix
    end

    def remove_long_routes(routes)
      ended_routes = routes.select { |route| route[:ended] }
      shortest_ended_route = ended_routes.min_by { |route| route[:total_weight] }

      if shortest_ended_route
        routes.reject! do |route|
          shortest_ended_route[:total_weight] < route[:total_weight]
        end
      end
    end    

  private
end
