# -*- coding: utf-8 -*-

require 'time'

class Rgraphum::Analyzer::RTAtMark

#  class Rgraphum::Vertex
#    field :twits
#  end

  def make_graph(twits)
    @graph = Rgraphum::Graph.new

    make_vertices(twits)
    make_edges(twits)

    @graph
  end

  def make_vertices(twits,graph=@graph)
    graph.vertices = twits.map{ |twit| { label:twit[7] } }.uniq!
    twits.each do |twit|
      vertex = graph.vertices.where(label: twit[7]).first
      vertex.twits ||= []
      vertex.twits << twit.compact
    end
  end

  def make_edges(twits,graph=@graph)
    twits.each_with_index do |twit|
      next unless atmark_screen_name = pickup_screen_name(twit[8])
      source_vertex = graph.vertices.where(label: atmark_screen_name).first
      source_vertex = graph.vertices.build(label: atmark_screen_name) unless source_vertex 
      target_vertex = graph.vertices.where(label: twit[7]).first
      graph.edges << {source:source_vertex,target:target_vertex,label:twit[8],start:Time.parse(twit[11])}
    end
  end

  def pickup_screen_name(text)
    return nil unless screen_name = text.match(/(^|[^@0-9_a-zA-Z])@[0-9_a-zA-Z]+($|[^@0-9_a-zA-Z])/)
    return nil unless screen_name = screen_name[0].gsub(/[^0-9_a-zA-Z]/,"").downcase
    screen_name
  end

end
