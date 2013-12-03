# -*- coding: utf-8 -*-

require 'test_helper'
require 'rgraphum'

class RgraphumCommunitiesTest < MiniTest::Unit::TestCase
  def setup
  end

  def test_new_communities
    communities = Rgraphum::Communities.new

    assert_empty communities
  end

  def test_communities_with_1_community
    communities = Rgraphum::Communities.new
    community = communities.build({})

    assert_equal 1, communities.size
    assert_same community, communities[0]
  end

  def test_converter
    communities = Rgraphum::Communities.new
    communities2 = Rgraphum::Communities(communities)

    assert_same communities, communities2
  end

  def test_delete
    communities = Rgraphum::Communities.new
    c1 = communities.build(id: 1)
    c2 = communities.build(id: 2)
    c3 = communities.build(id: 3)
    c4 = communities.build(id: 4)
    c5 = communities.build(id: 5)

    assert_equal 5, communities.size
    assert_equal [1,2,3,4,5], communities.map(&:id)

    communities.delete c2

    assert_equal 4, communities.size
    assert_equal [1,3,4,5], communities.map(&:id)


    communities.delete c5.id

    assert_equal 3, communities.size
    assert_equal [1,3,4], communities.map(&:id)
  end
end
