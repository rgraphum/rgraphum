# -*- coding: utf-8 -*-

require "open3"

module Rgraphum::Parsers
  # Graphviz is Graph drowing application.
  # Using dot formatted file, it drow picture.
  # This class make dot formatted file from graph and write file
  # if you want to know details, please see graphviz manual
  class GraphvizParser
    class << self
      # build graphviz file(.dot) content as string
      # @param [Rgraphum::Graph] graph target graph .
      # @param [String] layout type of layout, "dot", "neato", "fdp", "sfdp", "twopi", "circo". please see graphviz manual.
      def builder(graph, layout="dot")
        dot = "digraph #{graph.label || "sample"} { \n"
        dot += "  graph [ layout = \"#{layout}\", overlap = false ] \n\n"

        graph.edges.each do |edge|
          s = edge[:source][:label] || edge[:source][:id]
          t = edge[:target][:label] || edge[:target][:id]
          label = "[label = \"#{edge[:label]}\"]" if edge[:label]
          dot += "  \"#{s}\" -> \"#{t}\" #{label}; \n"
        end

        dot += "}"

        dot
      end

      # save graph as .dot and image files
      #
      # @param [Rgraphum::Graph] graph
      # @param [String]          path_prefix  Will create path_prefix.{dot,*} files
      # @param [String]          type         picture type, "jpeg", "jpg", "png" and etc..
      #
      def export(graph, path_prefix, type)
        dot = builder(graph)
        open("#{path_prefix}.dot", "w") do |file|
          file.write(dot)
        end
        cmd = "dot -T#{type} #{path_prefix}.dot -o #{path_prefix}.#{type}"
        o, e, s = Open3.capture3(cmd)
      end
    end

    def initialize(options={})
      default_options = {
        layout: "dot",
      }
      @options = default_options.merge(options)
      builder(@options[:graph]) if @options.key?(:graph)
    end

    # dot output builder
    # it call only class.method
    # @see GraphvizParser::builder
    def builder(graph)
      @dot = self.class.builder(graph, @options[:layout])
    end

    # save dot file and image
    # @param [String]          path_prefix  Will create path_prefix.{dot,*} files
    # @param [String]          type         picture type, "jpeg", "jpg", "png" and etc..
    def export(path_prefix, type=nil)
      graph = @options[:graph]
      builder(graph) unless @dot
      self.class.export(graph, path_prefix, type)
    end

    def to_s
      unless @dot
        raise ArgumentError, "Didn't build dot with builder(graph)"
      end
      @dot
    end
  end
end
