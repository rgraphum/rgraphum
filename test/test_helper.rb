# -*- coding: utf-8 -*-

require 'minitest/autorun'
require 'tempfile'
require 'pp'

class MiniTest::Unit::TestCase
  def assert_breakpoint!(on=true)
    @breakpoint = on
  end
end

