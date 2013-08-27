# -*- coding: utf-8 -*-

require 'json'

module Rgraphum::Parsers
  class MiserablesParser
    class << self
      def builder(graph)
        stream = "var miserables = { vertices: ["

        graph.vertices.each_with_index do |vertex, n|
          vertex.class_eval { attr_accessor :no } # FIXME
          vertex.no = n
          # stream += "\n{vertexName: \"#{vertex.label}\", group: #{vertex[:community_id]}},"
          stream += "\n" + { vertexName: vertex.label, group: vertex.community_id }.to_json + ","
        end
        stream.chop!
        stream += "],\n"

        stream += "links: ["
        graph.edges.each do |edge|
          stream += "\n{source: #{edge.source.no},"
          stream += " target: #{edge.target.no},"
          stream += " value: #{edge.weight}},"
        end
        stream.chop!
        stream += "]\n"
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
