

class Dijkstra

  def initialize
    @target_source_min_distance_path_hash = {}
  end

  def target_source_min_distance_path_hash( vertex )

    @target_source_min_distance_path_hash[vertex] ||= {}
    @target_source_min_distance_path_hash[vertex][vertex] ||= {}
    @target_source_min_distance_path_hash[vertex][vertex][:distance] = 0
    @target_source_min_distance_path_hash[vertex][vertex][:path]     = [vertex]

    out_edges = vertex.out_edges.sort{ |a,b| a.weight <=> b.weight }

    out_edges.each do |out_edge|
      target = out_edge.target
      airo = true
      @target_source_min_distance_path_hash[target] ||={}
      @target_source_min_distance_path_hash[vertex].each do |source,distance_path|
        next_distance = distance_path[:distance] + out_edge.weight
        @target_source_min_distance_path_hash[target][source] ||= {}
        if !@target_source_min_distance_path_hash[target][source][:distance] or @target_source_min_distance_path_hash[target][source][:distance] > next_distance
          airo = false
          @target_source_min_distance_path_hash[target][source][:distance]   = next_distance
          @target_source_min_distance_path_hash[target][source][:path]     ||=[]
          @target_source_min_distance_path_hash[target][source][:path]       = distance_path[:path] + [target]
        end
      end

      next if airo 
      self.target_source_min_distance_path_hash( target ) # self call
    end

    @target_source_min_distance_path_hash
  end

  def distance(a,b)
    if @target_source_min_distance_path_hash[b] and @target_source_min_distance_path_hash[b][a]
      @target_source_min_distance_path_hash[b][a][:distance]
    else
      target_source_min_distance_path_hash( a )[b][a][:distance]
    end
  end

  def path(a,b)
    if @target_source_min_distance_path_hash[b] and @target_source_min_distance_path_hash[b][a]
      @target_source_min_distance_path_hash[b][a][:path]
    else
      target_source_min_distance_path_hash( a )[b][a][:path]
    end
  end

end
