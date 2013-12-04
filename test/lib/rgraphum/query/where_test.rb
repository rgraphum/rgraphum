# -*- coding: utf-8 -*-

require 'rgraphum'
require 'test_helper'

class RgraphumQueryWhereTest < MiniTest::Unit::TestCase
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

  def test_where_and_all
    items = @query.where(label: "aaa").all
    assert_equal [1, 5, 9], items.map(&:id)
  end

  def test_where_and_all_without_matches
    items = @query.where(label: "xyz").all
    assert_empty items
  end

  def test_where_and_first_1
    item = @query.where(id: 3).first
    assert_equal 3, item.id
  end

  def test_where_and_first_2
    item = @query.where(id: 2).where(label: "bbb").first
    assert_equal 2, item.id
  end

  def test_where_and_first_without_matches
    item = @query.where(id: 2).where(label: "xyz").first
    assert_nil item
  end

  def test_where_and_last
    item = @query.where(label: "bbb").last
    assert_equal 10, item.id
  end

  def test_where_and_last_without_matches
    item = @query.where(label: "xyz").last
    assert_nil item
  end
end
