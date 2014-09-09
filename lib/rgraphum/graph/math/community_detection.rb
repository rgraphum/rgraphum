# -*- coding: utf-8 -*-

module  Rgraphum::Graph::Math
end

# Community Detection by Girvan?Newman algorithm
#   1st Set all vertex on each uniq communiy
#   2nd find edges within communities and make communities pair 
#   3rd calc delta_q if marge communities pair 
#   4th max delta_q communities pair is marged
#   5th update delta_q and do 4th
#   6th if dalta_q <= limit, stop community detection
class Rgraphum::Graph::Math::CommunityDetection

  def initialize(graph,limit = 0)
    @graph       = graph
    @m           = graph.m_with_weight
    @limit       = 0

    @modularity = 0
    @id_community_hash = {}
    initial_modularity_and_communities
    @delta_q_hash = {}
    initial_delta_q_hash

  end

  # modularity
  # main loop of community_detection and cale modularity with delta_q( = delta_modularity )
  #
  def modularity
    delta_q_sum = @modularity * (2.0 * @m ** 2)

    loop do
      (community_id_a, community_id_b), delta_q = @delta_q_hash.max { |a, b| a[1] <=> b[1] }

      break unless delta_q
      break if delta_q <= @limit

      delta_q_sum += delta_q

      community_a = @id_community_hash[community_id_a]
      community_b = @id_community_hash[community_id_b]

      community_a.merge(community_b)
      @delta_q_hash = update_delta_q_hash(community_id_a, community_id_b, @delta_q_hash)
    end

    @modularity = delta_q_sum / (2.0 * @m ** 2)
  end

  
  def initial_modularity_and_communities
    @modularity = 0
    @graph.vertices.each_with_index do |vertex, i|
      vertex.community_id = i
      unless vertex.edges.size == 0
        community = Rgraphum::Community.new(id: vertex.community_id, graph: self, vertices: [vertex])
        @id_community_hash[i] = community
        @modularity -= vertex.degree_weight.to_f ** 2
      end
    end
    @modularity = @modularity / (2.0 * @m ) ** 2
  end

  # delta_q_hash: Hash
  #   key:   [community_a.id, community_b.id] # Array of Integer
  #   value: delta_q_seed # Float
  def initial_delta_q_hash( limit=0 )
    @graph.edges.each do |edge|
      s_c_id = edge.source.community_id
      t_c_id = edge.target.community_id

      # don't use loop
      next if s_c_id == t_c_id

      key = [ s_c_id, t_c_id ].sort!

      delta_q_seed = delta_q_seed( @id_community_hash[ key[0] ] , @id_community_hash[ key[1] ] )
      next if delta_q_seed <= limit
      @delta_q_hash[key] = delta_q_seed
    end
  end


  # ΔQ = Qa - Qb
  def delta_q(community_a, community_b)
    seed = delta_q_seed(community_a, community_b)
    seed / (2.0 * @m ** 2)
  end

  private

  def update_delta_q_hash(community_id_a, community_id_b, delta_q_hash)
    a_id = community_id_a
    b_id = community_id_b

    new_keys = []
    used_keys = []

    @delta_q_hash.delete( [a_id,b_id] )

    # b_id -> a_id
    @delta_q_hash.delete_if do |key,value|
      next false unless index = key.index(b_id)

      key_dup = key.dup
      key_dup[index] = a_id
      
      key_dup.sort!
      new_keys << key_dup
      true
    end

    new_keys.each do |key|
      @delta_q_hash[key] = 0.0
    end

    # update delta_q_value in a_id
    community_a = @id_community_hash[a_id]
#   @delta_q_hash.each do |key, value|
    @delta_q_hash.delete_if do |key, value|
      if a_key_index = key.index(a_id)
        o_key_index = a_key_index - 1
        o_id = key[o_key_index]
        other_community = @id_community_hash[o_id]

        delta_q_seed = delta_q_seed(community_a, other_community)
        next true if delta_q_seed <= @limit
        @delta_q_hash[key] = delta_q_seed
      end
      false
    end

    @delta_q_hash
  end

  def delta_q_seed(community_a, community_b)
    tot_i = community_a.degree_weight
    tot_j = community_b.degree_weight

    ki_in = community_a.edges_from(community_b).inject(0) { |sum, edge| sum + edge.weight }

    2.0 * @m * ki_in - tot_i * tot_j
  end

end
