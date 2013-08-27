# -*- coding: utf-8 -*-

require 'test_helper'
require 'rgraphum'

class RgraphumSimulatorTest < MiniTest::Test
  include Rgraphum::Simulator

  def setup
  end

  def test_guess_model_class
    assert_equal Rgraphum::Simulator::BAModel, guess_model_class("BAModel")
    assert_equal Rgraphum::Simulator::BAModel, guess_model_class("ba_model")
    assert_equal Rgraphum::Simulator::BAModel, guess_model_class("BAmodel")

    assert_equal Rgraphum::Simulator::SISModel, guess_model_class("SISmodel")
    assert_equal Rgraphum::Simulator::SISModel, guess_model_class("SIS Model")
    assert_equal Rgraphum::Simulator::SISModel, guess_model_class("SISModel")
    assert_equal Rgraphum::Simulator::SISModel, guess_model_class("sismodel")
  end
end
