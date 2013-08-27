# -*- coding: utf-8 -*-

module Rgraphum::Graph::Math

  class DegreeDistribution
    attr_reader :degree_distribution

    def initialize(graph)
      degree_distribution = {}

      graph.vertices.each do |vertex|
        degree_distribution[vertex.degree] ||= 0
        degree_distribution[vertex.degree] += 1
      end

      @degree_distribution = {}
      degree_distribution.each do |key, value|
        @degree_distribution[key] = value.to_f / graph.vertices.size
      end

      self
    end

    def exponent
      loged_degree_distribution = to_log
      ral = Rgraphum::Analyzer::LinearRegression.new
      ral.analyze(loged_degree_distribution.keys, loged_degree_distribution.values).first
    end

    def to_log
      output ={}
      @degree_distribution.each do |key,value|
        output[Math.log(key, 10)] = Math.log(value, 10)
      end
      output
    end
  end

  def degree_distribution(force=false)
    @degree_distribution = nil if force
    @degree_distribution ||= DegreeDistribution.new(self)
    @degree_distribution.degree_distribution
  end

  def degree_distribution_exponent(force=false)
    @degree_distribution = nil if force
    @degree_distribution ||= DegreeDistribution.new(self)
    @degree_distribution.exponent
  end
end
