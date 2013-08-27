# -*- coding: utf-8 -*-

module Rgraphum::Simulator
  require_relative 'simulator/ba_model'
  require_relative 'simulator/sis_model'
  require_relative 'simulator/sir_model'

  MODEL_NAME_MODEL_MAP = {
    "bamodel"  => Rgraphum::Simulator::BAModel,
    "sismodel" => Rgraphum::Simulator::SISModel,
    "sirmodel" => Rgraphum::Simulator::SIRModel,
  }

  def simulate(model_name, options={})
    model_class = guess_model_class(model_name)
    new_options = options.merge(graph: self)
    simulator = model_class.new(new_options)
    simulator.simulate(options)
  end

  private

  def guess_model_class(model_name)
    name = model_name.dup.downcase.gsub(/[^a-z0-9]/, "")
    model = MODEL_NAME_MODEL_MAP[name]
    return model if model
    raise ArgumentError, "Simulator model not found: '#{model_name}'"
  end
end
