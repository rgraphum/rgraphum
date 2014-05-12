# -*- coding: utf-8 -*-

require 'minitest/autorun'
require 'tempfile'
require 'pp'

class MiniTest::Unit::TestCase
  # Add more helper methods to be used by all tests here...

  # alias :original_assert_equal :assert_equal
  #
  # # assert_equal(exp, act, msg = nil)
  # def assert_equal(exp, act, msg = nil)
  #   binding.pry if @breakpoint
  #   exp = exp.to_hash if exp.is_a?(Rgraphum::Vertex) || exp.is_a?(Rgraphum::Edge)
  #   act = act.to_hash if act.is_a?(Rgraphum::Vertex) || act.is_a?(Rgraphum::Edge)
  #   if exp.is_a?(Rgraphum::RgraphumArray)
  #     exp = exp.map(&:to_hash)
  #   elsif exp.is_a?(Array) && exp.find { |item| item.is_a?(Rgraphum::Vertex) || item.is_a?(Rgraphum::Edge) }
  #     exp = exp.map(&:to_hash)
  #   end
  #   if act.is_a?(Rgraphum::RgraphumArray)
  #     act = act.map(&:to_hash)
  #   elsif act.is_a?(Array) && act.find { |item| item.is_a?(Rgraphum::Vertex) || item.is_a?(Rgraphum::Edge) }
  #     act = act.map(&:to_hash)
  #   end
  #   original_assert_equal(exp, act, msg)
  # end

#  def rg_assert_equal(exp, act, msg = nil)
#    binding.pry if @breakpoint
#    exp, act = rg_convert_exp_and_act(exp, act)
#    assert_equal(exp, act, msg)
#  end

  def rg_refute_equal(exp, act, msg = nil)
    binding.pry if @breakpoint
    exp, act = rg_convert_exp_and_act(exp, act)
    refute_equal(exp, act, msg)
  end

  def assert_breakpoint!(on=true)
    @breakpoint = on
  end

  private

  def rg_convert_exp_and_act(exp, act)
    exp = exp.to_hash if exp.is_a?(Rgraphum::Vertex) || exp.is_a?(Rgraphum::Edge)
    act = act.to_hash if act.is_a?(Rgraphum::Vertex) || act.is_a?(Rgraphum::Edge)
    if exp.is_a?(Rgraphum::RgraphumArray)
      exp = exp.map(&:to_hash)
    elsif exp.is_a?(Array) && exp.find { |item| item.is_a?(Rgraphum::Vertex) || item.is_a?(Rgraphum::Edge) }
      exp = exp.map(&:to_hash)
    end
    if act.is_a?(Rgraphum::RgraphumArray)
      act = act.map(&:to_hash)
    elsif act.is_a?(Array) && act.find { |item| item.is_a?(Rgraphum::Vertex) || item.is_a?(Rgraphum::Edge) }
      act = act.map(&:to_hash)
    end
    [exp, act]
  end
end

module ClearVerticesAndEdgesIdHolder
  def before_setup
    super
    Rgraphum::Vertices.reset_id
    Rgraphum::Edges.reset_id
  end
end

class MiniTest::Unit::TestCase
  include ClearVerticesAndEdgesIdHolder
end

module Minitest
  class Assertion
    # def location
    #   last_before_assertion = ""
    #   self.backtrace.reverse_each do |s|
    #     break if s =~ /in .(assert|refute|flunk|pass|fail|raise|must|wont)/
    #     last_before_assertion = s
    #   end
    #   last_before_assertion.sub(/:in .*$/, "")
    # end

    def location
      last_before_assertion = ""
      self.backtrace.reverse_each do |s|
        break if s =~ /in .(rg_|)(assert|refute|flunk|pass|fail|raise|must|wont)/
        last_before_assertion = s
      end
      last_before_assertion.sub(/:in .*$/, "")
    end
  end
end
