

class Dijkstra

  def initialize
    @target_source_min_distance_path_hash = {}
    @analized_vertices = []
  end

  def analized?(vertex)
    @analized_vertices.include?(vertex)
  end

  def distance(a,b)
    if analized?(a)
      @target_source_min_distance_path_hash[b][a][:distance]
    else
      hash_tmp = target_source_min_distance_path_hash( a )
      return false unless hash_tmp[b][a]
      hash_tmp[b][a][:distance]
    end
  end

  def distance_one_to_n(one)
    if analized?(one)
      target_min_distance_hash(one)
    else
      target_source_min_distance_path_hash( one )
      target_min_distance_hash(one)
    end
  end

  def path(a,b)
    if analized?(a)
      @target_source_min_distance_path_hash[b][a][:path]
    else
      hash_tmp = target_source_min_distance_path_hash( a )
      return false unless hash_tmp[b][a]
      hash_tmp[b][a][:path]
    end
  end

  def path_one_to_n(one)
    if analized?(one)
      target_min_path_hash(one)
    else
      target_source_min_distance_path_hash( one )
      target_min_path_hash(one)
    end
  end

  def cluster(a,b,used_vertices=[])
    vertices = []
    n_path = path_one_to_n(a)
    return [] unless @target_source_min_distance_path_hash[b]
    interchange_vertices = n_path.values.flatten.uniq
    interchange_vertices.each do |vertex|
      path = @target_source_min_distance_path_hash[b][vertex][:path] if @target_source_min_distance_path_hash[b][vertex]
      next unless path
      vertices.concat(path) 
    end

    vertices.uniq - used_vertices
  end

  def cluster_one_to_n(a)
    tmp = {}
    path_one_to_n(a).keys.each do |b|
      tmp[b] = cluster(a,b)
    end
    tmp
  end

#####################
  def target_source_min_distance_path_hash( vertex )
    # make start point
    target_source_min_distance_path_hash_init(vertex)

    out_edges = vertex.out_edges.load.sort{ |a,b| a.weight <=> b.weight }

    out_edges.each_with_index do |out_edge,index|
      target = out_edge.target
      unless airo_check_and_update(out_edge) 
        next if analized?(target)

        target_source_min_distance_path_hash_init(target)

        target_out_edges = target.out_edges.load.sort{ |a,b| a.weight <=> b.weight }
        out_edges.concat(target_out_edges)
        
      end
    end 
    @target_source_min_distance_path_hash
  end

  def target_source_min_distance_path_hash_init(vertex)
    @analized_vertices << vertex
    @target_source_min_distance_path_hash[vertex] ||= {}
    @target_source_min_distance_path_hash[vertex][vertex] ||= {}
    @target_source_min_distance_path_hash[vertex][vertex][:distance] = 0
    @target_source_min_distance_path_hash[vertex][vertex][:path]     = [vertex]
  end

  def airo_check_and_update(edge)
    airo = true
    pre_vertex = edge.source
    interchange = edge.target

    @target_source_min_distance_path_hash[interchange] ||={}
    @target_source_min_distance_path_hash[pre_vertex].each do |source,distance_path|
      next_distance = distance_path[:distance] + edge.weight
      @target_source_min_distance_path_hash[interchange][source] ||= {}
      if !@target_source_min_distance_path_hash[interchange][source][:distance] or @target_source_min_distance_path_hash[interchange][source][:distance] > next_distance
        airo = false
        @target_source_min_distance_path_hash[interchange][source][:distance]   = next_distance
        @target_source_min_distance_path_hash[interchange][source][:path]     ||= []
        @target_source_min_distance_path_hash[interchange][source][:path]       = distance_path[:path] + [interchange]

        target_min_distance_hash(interchange).each do |target,distance|
          @target_source_min_distance_path_hash[target][source] ||= {}
          if !@target_source_min_distance_path_hash[target][source][:distance] or @target_source_min_distance_path_hash[target][source][:distance] > distance + next_distance
            @target_source_min_distance_path_hash[target][source][:distance] = distance + next_distance
            @target_source_min_distance_path_hash[target][source][:path] =  distance_path[:path] + @target_source_min_distance_path_hash[target][interchange][:path]
          end
        end
      end
    end
    airo
  end

  def target_min_distance_hash(source)
    target_min_distance_hash = {}
    @target_source_min_distance_path_hash.each do |target,source_distance_path|
      target_min_distance_hash[target] = source_distance_path[source][:distance] if source_distance_path[source]
    end
    target_min_distance_hash
  end

  def target_min_path_hash(source)
    target_min_distance_hash = {}
    @target_source_min_distance_path_hash.each do |target,source_distance_path|
      target_min_distance_hash[target] = source_distance_path[source][:path] if source_distance_path[source]
    end
    target_min_distance_hash
  end
end
