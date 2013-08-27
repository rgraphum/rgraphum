# -*- coding: utf-8 -*-

require 'rgraphum'
require 'test_helper'

class RgraphumQueryWhereOperatorsTest < MiniTest::Test
  def setup
    @array = [
      OpenStruct.new(id: 1,  label: "aaa"),
      OpenStruct.new(id: 2,  label: "bbb"),
      OpenStruct.new(id: 3,  label: "ccc"),
      OpenStruct.new(id: 4,  label: "ddd"),
      OpenStruct.new(id: 5,  label: "aaa"),
      OpenStruct.new(id: 6,  label: "bbb"),
      OpenStruct.new(id: 7,  label: "ccc"),
      OpenStruct.new(id: 8,  label: "ddd"),
      OpenStruct.new(id: 9,  label: "aaa"),
      OpenStruct.new(id: 10, label: "bbb"),
      OpenStruct.new(id: 11, label: "ccc"),
      OpenStruct.new(id: 12, label: "ddd"),
    ]
    @query = Rgraphum::Query.new(@array)
  end

  def test_where_eq_1
    items = @query.where(:label, :eq, "aaa").all
    assert_equal [1, 5, 9], items.map(&:id)
  end

  def test_where_eq_2
    items = @query.where(:id, :eq, 3).all
    assert_equal [3], items.map(&:id)
  end

  def test_where_ne
    items = @query.where(:id, :ne, 3).all
    assert_equal [1,2,4,5,6,7,8,9,10,11,12], items.map(&:id)
  end

  def test_where_gt
    items = @query.where(:id, :gt, 6).all
    assert_equal [7,8,9,10,11,12], items.map(&:id)
  end

  def test_where_gte
    items = @query.where(:id, :gte, 6).all
    assert_equal [6,7,8,9,10,11,12], items.map(&:id)
  end

  def test_where_lt
    items = @query.where(:id, :lt, 6).all
    assert_equal [1,2,3,4,5], items.map(&:id)
  end

  def test_where_lte
    items = @query.where(:id, :lte, 6).all
    assert_equal [1,2,3,4,5,6], items.map(&:id)
  end

  def test_where_match
    items = @query.where(:label, :match, /^a+$/).all
    assert_equal [1,5,9], items.map(&:id)

    items = @query.where(:label, :=~, /^a+$/).all
    assert_equal [1,5,9], items.map(&:id)
  end

  def test_where_not_match
    items = @query.where(:label, :not_match, /^a+$/).all
    assert_equal [2,3,4,6,7,8,10,11,12], items.map(&:id)

    items = @query.where(:label, :!~, /^a+$/).all
    assert_equal [2,3,4,6,7,8,10,11,12], items.map(&:id)
  end
end
