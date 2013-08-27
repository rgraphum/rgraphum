# -*- coding: utf-8 -*-

require 'json'

module Rgraphum::Parsers
  class FlareParser
    class << self
      #
      def builder(graph)
        stream = "var flare = { \"#{graph.label}\" : "

        vertices_hash = {}
        graph.vertices.each do |vertex|
          vertices_hash[vertex.label] = vertex.amount
        end
        stream += vertices_hash.to_json
        stream += "};"
        stream
      end
    end

    # Options:
    #
    def initialize(options={})
      default_options = {
      }
      @options = default_options.merge(options)
      builder(@options[:graph]) if @options.key?(:graph)
    end

    def builder(graph)
      @stream = self.class.builder(graph)
    end

    def to_s
      unless @stream
        raise ArgumentError, "Didn't build stream with builder(graph)"
      end
      @stream
    end
  end
end
