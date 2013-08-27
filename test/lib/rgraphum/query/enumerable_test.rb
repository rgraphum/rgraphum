# -*- coding: utf-8 -*-

require 'test_helper'
require 'rgraphum'

class RgraphumQueryEnumerableTest < MiniTest::Test
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
    items = @query.where(label: "aaa") # .all
    assert_equal [1, 5, 9], items.map(&:id)
  end

  def test_where_and_all_without_matches
    items = @query.where(label: "xyz") # .all
    assert_empty items
  end

  def test_each
    items = []
    @query.where(label: "ccc").each do |item|
      items << item
    end
    assert_equal [3, 7, 11], items.map(&:id)
  end
end
