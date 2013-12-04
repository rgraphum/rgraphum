# -*- coding: utf-8 -*-

require 'test_helper'
require 'rgraphum'

class RgraphumMathCommunityTest < MiniTest::Unit::TestCase
  def setup
    #  1 - 2
    #   \ /
    #    3
    #   / \
    #  4 - 5

    @graph = Rgraphum::Graph.new
    @graph.vertices = [
      { id: 1, label: "A", community_id: 1 },
      { id: 2, label: "B", community_id: 1 },
      { id: 3, label: "C" },
      { id: 4, label: "D" },
      { id: 5, label: "E" },
    ]
    @graph.edges = [
      { id: 0, source: 1, target: 2, weight: 1 },
      { id: 1, source: 1, target: 3, weight: 1 },
      { id: 2, source: 2, target: 3, weight: 1 },
      { id: 3, source: 3, target: 4, weight: 1 },
      { id: 4, source: 3, target: 5, weight: 1 },
      { id: 5, source: 4, target: 5, weight: 1 },
    ]
  end

  def test_community
    #  1 - 2
    #   \ /
    #    3
    #   / \
    #  4 - 5
    # (1-2) communityy

    @graph.id_aspect!
    community = @graph.communities[0]

    assert community
    assert_instance_of Rgraphum::Community, community
    assert_equal 1, community.id
    expected = [
      { id: 0, source: 1, target: 2, weight: 1 },
      { id: 1, source: 1, target: 3, weight: 1 },
      { id: 2, source: 2, target: 3, weight: 1 },
    ]
    rg_assert_equal expected, community.edges

    rg_assert_equal [{ id: 0, source: 1, target: 2, weight: 1 }], community.inter_edges
    expected = [
      { id: 1, source: 1, target: 3, weight: 1 },
      { id: 2, source: 2, target: 3, weight: 1 },
    ]
    rg_assert_equal expected, community.edges_from(@graph.vertices.where(id: 3).first)
    assert_empty community.edges_from(@graph.vertices.where(id: 4).first)

    @graph.edges.where(id: 0).first.weight = 4
    @graph.edges.where(id: 1).first.weight = 1
    @graph.edges.where(id: 2).first.weight = 2
    @graph.edges.where(id: 3).first.weight = 3
    @graph.edges.where(id: 4).first.weight = 5
    @graph.edges.where(id: 5).first.weight = 6

    assert_equal 11, community.degree_weight
    assert_equal 4,  community.sigma_in

    assert_equal 11, @graph.vertices.where(id: 3).first.sigma_tot

    @graph.real_aspect!
    rmcd = Rgraphum::Graph::Math::CommunityDetection.new(@graph)
    delta_q = rmcd.delta_q(community,@graph.vertices.where(id: 3).first)
    assert_in_delta 0.00566893, delta_q, 0.00000001
  end
end
