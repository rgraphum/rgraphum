# -*- coding: utf-8 -*-

require 'rgraphum'
require 'test_helper'

class RgraphumIDsManagerTest < MiniTest::Unit::TestCase

  include ElementsManager

  def test_initialize
    ids_manager = ElementsManager.new
  end

end
