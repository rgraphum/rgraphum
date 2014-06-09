# -*- coding: utf-8 -*-

require_relative 'phrase_cluster'

class Rgraphum::Graph
  # pickup start vertices
  # it mean pick vertices having no in degree
  def start_root_vertices
    vertices.select do |vertex|
      vertex.inE.empty?
    end
  end

  # pickup end vertices
  # it mean pick vertices having no out degree
  def end_root_vertices
    vertices.select do |vertex|
      vertex.outE.empty?
    end
  end
end

class Rgraphum::Analyzer::MemeTracker
  attr_accessor :distance_max_limit
  attr_accessor :graph
  attr_accessor :clusters

  def initialize(graph=Rgraphum::Graph.new)
    @distance_max_limit = 5
    self.graph = graph
  end

  def edit_distance(words_a, words_b, limit=@distance_max_limit)
    a = words_a.dup
    b = words_b.dup

    return nil if (a - b | b - a).size  > (limit * 2)
    d = find_shift_distance(a, b)
  end

  def find_shift_distance(words_a, words_b, depth=0)
    return nil if depth > @distance_max_limit

    return words_b.size if words_a.empty?
    return words_a.size if words_b.empty?

    shifted_words_a = words_a[1..-1]
    shifted_words_b = words_b[1..-1]

    if words_a[0] == words_b[0]
      return find_shift_distance(shifted_words_a, shifted_words_b, depth)
    else
      depth += 1
      distance = 1
      distance_a = find_shift_distance(words_a, shifted_words_b, depth)
      distance_b = find_shift_distance(shifted_words_a, words_b, depth)
      distance_c = find_shift_distance(shifted_words_a, shifted_words_b, depth)
      if delta_distance = [distance_a, distance_b, distance_c].compact.min
        return distance += delta_distance
      else
        return nil
      end
    end
  end

  ###############################################################

  def phrase_clusters
    new_graph = @graph.dup
    graph_start_root_vertices = start_root_vertices(new_graph)
    graph_end_root_vertices   = end_root_vertices(new_graph)

    end_root_vertex_path_hashs, end_root_vertex_path_hash_keys_array = [], []
    graph_start_root_vertices.each do |graph_start_root_vertex|
      end_root_vertex_path_hash = build_end_root_vertex_path_hash(graph_start_root_vertex)
      end_root_vertex_path_hashs << end_root_vertex_path_hash
      end_root_vertex_path_hash_keys_array << end_root_vertex_path_hash.paths.map { |path| path.end_vertex }
    end

    end_root_vertex_path_hash_kyes_array = vertex_id_map(end_root_vertex_path_hash_keys_array)

    # sets {end_path_key => start_root_vertex}
    sets = {}
    end_root_vertex_path_hashs.each_with_index do |end_root_vertex_path_hash, i|
      end_root_vertex_path_hash_keys_array.each do |end_path_keys|
        unless (end_root_vertex_path_hash.paths.map { |path| path.end_vertex } & end_path_keys).empty?
          sets[end_path_keys] ||= []
          sets[end_path_keys] << graph_start_root_vertices[i]
          break
        end
      end
    end

    sets = sets.map{ |end_path_keys, end_path_start_root_vertices|
      [end_path_start_root_vertices, end_path_keys]
    }

    clusters = []
    sets.each do |end_path_start_root_vertices, end_path_keys|
      end_path_start_root_vertices_pt = end_path_start_root_vertices.permutation
      end_path_keys_pt = end_path_keys.repeated_permutation(end_path_start_root_vertices.size)
      communities_set = []
      end_path_start_root_vertices_pt.each_with_index do |end_path_start_root_vertices_p, i|
        end_path_keys_pt.each_with_index do |end_path_keys_p, j|
          communities_set << make_communities(end_path_start_root_vertices_p, end_path_keys_p)
        end
      end

      sigma_in_sizes = communities_set.map { |communities| sum_sigma_in(communities) }
      max = sigma_in_sizes.max
      index = sigma_in_sizes.index(max)

      clusters += communities_set[index]
    end
    clusters
  end

  def vertex_id_map(cluster_keys)
#    [cluster_keys.flatten.uniq]
    return cluster_keys if cluster_keys.size < 2
    id_map = cluster_keys.dup

    cluster_keys.combination(2).each do |a, b|
      unless (a & b).empty?
        id_map.delete(a)
        id_map.delete(b)
        id_map << (a | b)
      end
    end

    if id_map.size == cluster_keys.size
      cluster_keys
    else
      vertex_id_map(id_map)
    end
  end

  def sum_sigma_in(communities)
    communities.inject(0) { |size, community|
      size + community.sigma_in
    }
  end

  def make_communities(graph_start_root_vertices, graph_end_root_vertices)
    hashed_cluster = {}
    used_vertices = {}

    pair = [graph_start_root_vertices, graph_end_root_vertices].transpose

    pair.each do |start_vertex, end_vertex|
      cluster, used_vertices = find_cluster_with_used_vertices(start_vertex, end_vertex, used_vertices)

      if cluster
        if hashed_cluster[end_vertex.id]
          hashed_cluster[end_vertex.id] = (hashed_cluster[end_vertex.id] | cluster)
        else
          hashed_cluster[end_vertex.id] = cluster
        end
      end
    end

    communities = hashed_cluster.map do |end_vertex_id, vertices|
      Rgraphum::Community.new(vertices: vertices)
    end

    Rgraphum::Communities(communities)
  end

  # NOTE cluster を探しているっぽい
  def find_cluster(start_vertex, end_vertex)
    cluster, used_vertices = find_cluster_with_used_vertices(start_vertex, end_vertex, {})
    cluster
  end

  def find_cluster_with_used_vertices(start_vertex, end_vertex, used_vertices)
    # FIXME rename cluster
    # used_vertices = { start_vertex => }
    if used_vertex = used_vertices[start_vertex]
      if used_vertex == end_vertex
        return [[], used_vertices]
      else
        return [nil, used_vertices]
      end
    end

    if start_vertex == end_vertex
      used_vertices[start_vertex] = end_vertex
      return [[start_vertex], used_vertices]
    else
      if start_vertex.out.empty?
        return nil, used_vertices
      end
    end

    cluster = nil
    start_vertex.out.each do |vertex|
      deep_cluster, used_vertices = find_cluster_with_used_vertices(vertex, end_vertex, used_vertices)

      if deep_cluster
        cluster ||= []
        cluster += deep_cluster
      end
    end

    if cluster
      cluster << start_vertex
      used_vertices[start_vertex] = end_vertex
    end

    [cluster, used_vertices]
  end

  # {end_root_vertex => [vertex,vertex],end_root_vertex => [vertex,vertex]}
  def build_end_root_vertex_path_hash(start_vertex, cluster=nil)
    cluster ||= Rgraphum::PhraseCluster.new
    start_vertex.out.each do |vertex|
      next if cluster.have_vertex_in_path?(vertex, start_vertex)

      if !vertex.out.empty? # not reach end_root_vertex, vertex != end_root_vertex
       # remove loop edge
       found = cluster.have_vertex?(vertex) && cluster.have_vertex?(start_vertex)
       next if found

        cluster = build_end_root_vertex_path_hash(vertex, cluster) # recursive call
        cluster.each_path do |path|
          if path.include?(vertex) and !path.include?(start_vertex)
            cluster.append_vertex path, start_vertex
          end
        end

      else
        if cluster.have_end_vertex?(vertex)
          path = cluster.find_path(vertex.id)
          cluster.append_vertex path, start_vertex
        else
          cluster.add_path Rgraphum::Path.new(vertex, [vertex, start_vertex])
        end
      end

    end
    cluster
  end

  def start_root_vertices(target_graph=@graph)
    target_graph.vertices.find_all{ |vertex| vertex.in.empty? and !vertex.out.empty? }
  end

  def end_root_vertices(target_graph=@graph)
    target_graph.vertices.find_all{ |vertex| !vertex.in.empty? and vertex.out.empty? }
  end

##################
  
  def find_path( options )
    options = { :vertices=>Rgraphum::Vertices.new, :cut => true }.merge(options)

    vertices = options[:vertices]

    source_vertex = options[:source_vertex]

    return vertices if vertices.include?(source_vertex)

    return vertices << source_vertex if source_vertex.out.empty? # if end_root_vertex
    path_vertices = source_vertex.out.inject(vertices) do |vertices, vertex|
      size = vertices.size
      vertices = find_path( {source_vertex:vertex,vertices:vertices} ) #
      if vertices.size == size and options[:cut] == true
        edge_to_delete = source_vertex.edges.where(target: vertex).first
        source_vertex.edges.delete(edge_to_delete)
      end
      vertices
    end
    path_vertices << source_vertex
  end

  def make_path_graph(graph=@graph)
    p "in make path graph" if Rgraphum.verbose?
    graph = graph.dup

    p "find srn" if Rgraphum.verbose?
    graph_start_root_vertices = start_root_vertices(graph)

    p "find path and to_graph" if Rgraphum.verbose?
    d = Dijkstra.new 
    graphes = graph_start_root_vertices.map do |vertex|
      path = find_path(source_vertex:vertex)
#      path = d.path_one_to_n(vertex)
      Rgraphum::Vertices.new(path).to_graph
    end
  end

  def cut_edges_with_srn(graph=@graph)
    new_graph = Rgraphum::Graph.new

    graphes = make_path_graph(graph)

    new_graph.vertices = graphes.map { |g| g.vertices }.flatten
    new_graph.edges = graphes.map { |g| g.edges }.flatten

    new_graph.compact_with(:id)
  end

  def count_same_words_vertices(graph=@graph)
    graph.vertices.combination(2).each do |vertex_a, vertex_b|
      vertex_a.count = vertex_a.count.to_i + 1 if vertex_a.words == vertex_b.words
    end
  end

  def make_edges(graph=@graph)
    graph.vertices.sort! { |a, b|  a.start.to_f <=> b.start.to_f }

    graph.vertices.combination(2).each_with_index do |pair, i|
      if pair[1].start and pair[0].end
        next unless  pair[0].within_term(pair[1])
      end

      distance = edit_distance(pair[0].words, pair[1].words)
      next unless distance

      graph.edges << { source: pair[0], target: pair[1], weight: (1.0 / (distance + 1)) }
    end

    graph.edges
  end

  def make_graph(phrase_array)
    @graph = Rgraphum::Graph.new
    @graph.vertices = phrase_array

    self.count_same_words_vertices(@graph)

    @graph.compact_with(:words, @graph)

    self.make_edges(@graph)

    @graph
  end
end
