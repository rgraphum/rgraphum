# -*- coding: utf-8 -*-

require 'rgraphum'
require 'test_helper'

class RgraphumIDsManagerTest < MiniTest::Unit::TestCase

  include IDs

  def test_initialize
    ids_manager = IDsManager.new
  end

end
