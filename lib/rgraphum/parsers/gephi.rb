# -*- coding: utf-8 -*-

require 'builder/xmlmarkup'

module Rgraphum::Parsers
  class GephiParser
    class << self
      def builder(graph)
        new.builder(graph)
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
      xml = ""
      @xmlobj = Builder::XmlMarkup.new(target: xml , indent: 2)
      set_header

      options = {
        "xmlns"              => "http://www.gexf.net/1.2draft",
        "xmlns:viz"          => "http://www.gexf.net/1.1draft/viz",
        "xmlns:xsi"          => "http://www.w3.org/2001/XMLSchema-instance",
        "xsi:schemaLocation" => "http://www.gexf.net/1.2draft http://www.gexf.net/1.2draft/gexf.xsd",
        "version"            => "1.2",
      }
      @xmlobj.gexf(options) do
        @xmlobj.meta(lastmodifieddate: Time.now.strftime("%Y-%m-%d")) do
          @xmlobj.creator("Gephi 0.8")
        end
        opts = {
          defaultedgetype: "directed",
          mode:       "dynamic",
          idtype:     "string",
          timeformat: "dateTime",
        }
        @xmlobj.graph(opts) do
          vertices_to_xml(graph.vertices)
          edges_to_xml(graph.edges)
        end
      end

      @xml = xml
      @xml
    end

    def to_s
      unless @xml
        raise ArgumentError, "Didn't build xml with builder(graph)"
      end
      @xml
    end

    private

    def vertices_to_xml(vertices)
      # Vertexの登録
      @xmlobj.nodes() do
        vertices.each do |vertex|
          node_to_xml(vertex)
        end
      end
    end
    alias :nodes_to_xml :vertices_to_xml

    def node_to_xml(vertex)
      new_vertex = vertex.dup
      new_vertex.start = time_format(vertex.start) if vertex.start
      new_vertex.end   = time_format(vertex.end)   if vertex.end

      @xmlobj.node(id: vertex.id, label: vertex.label) do
        # if vertex.attvalues and vertex.attvalues !=[]
        #   xmlobj.spells(){
        #     vertex.attvalues.each do |attvalue|
        #       opts = {
        #         start:   time_format(attvalue.start),
        #         endopen: time_format(attvalue.end),
        #       }
        #       @xmlobj.spell(opts)
        #     end
        #   }
        # end
      end
    end
    alias :vertex_to_xml :node_to_xml

    def edges_to_xml(edges)
      # @xmlobj.attributes(class: "edge", mode: "dynamic") do
      #   @xmlobj.attribute(id: "weight", title: "Weight", type: "float")
      # end
      @xmlobj.edges() do
        edges.each do |edge|
          edge_to_xml(edge.dup)
        end
      end
    end

    def edge_to_xml(edge)
      edge_opts = {
        id:     edge.id,
        source: edge.source.id,
        target: edge.target.id,
        label:  edge.label,
        weight: (edge.weight || 0.0),
      }
      @xmlobj.edge(edge_opts) do
        if edge.attvalues and !edge.attvalues.empty?
          mlobj.spells() do
            edge.attvalues.each do |attvalue|
              opts = {
                start:   time_format(attvalue.start),
                endopen: time_format(attvalue.end),
              }
              xmlobj.spell(opts)
            end
          end

          xmlobj.attvalues() do
            edge.attvalues.each do |attvalue|
              attrs = {
                :for   => "weight",
                :value => attvalue.weight.to_f,
                :start => time_format(attvalue.start),
                :end   => time_format(attvalue.end),
              }
              xmlobj.attvalue(attrs)
            end
          end
        end
      end
    end

    def make_spells_compact_with(field_name, graph, options={})
      graph.divide_by_time(60 * 8)

      new_vertices = Rgraphum::Vertices.new
      new_vertices.graph = graph

      graph.vertices.each do |vertex|
        same_vertex = new_vertices.find { |v|
          v.send(field_name) == vertex.send(field_name)
        }
        unless same_vertex
          new_vertex = vertex.dup
          new_vertex.edges = []
          new_vertices << new_vertex
        end
      end

      new_edges = Rgraphum::Edges.new

      graph.edges.each do |edge|
        source_label = edge.source.send(field_name)
        target_label = edge.target.send(field_name)

        edge.source = new_vertices.find { |vertex| vertex.send(field_name) == source_label }
        edge.target = new_vertices.find { |vertex| vertex.send(field_name) == target_label }

        new_edge = new_edges.find { |e|
          e.source == edge.source and e.source == edge.source
        }
        if new_edge
          new_edge.weight += edge.weight
        else
          new_edges << edge
        end
      end

      graph.vertices = new_vertices
      graph.edges = new_edges
      graph
    end

    def set_header
      @xmlobj.instruct! :xml, encoding: 'UTF-8'
    end

    def add_spells(vertex_a, vertex_b)
      raise NotImplementedError
    end

    def time_format(t)
      t.strftime("%Y-%m-%dT%H:%M:%S")
    end
  end
end
