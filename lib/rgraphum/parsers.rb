# -*- coding: utf-8 -*-

require_relative 'parsers/gephi'
require_relative 'parsers/miserables'
require_relative 'parsers/graphviz'
require_relative 'parsers/flare'

module Rgraphum::Parsers
  # parsers
  def to_gephi
    self.real_aspect! if @aspect == "id"
    gephi_xml = Rgraphum::Parsers::GephiParser.new(graph: self)
  end

  def to_miserables
    self.real_aspect! if @aspect == "id"
    stream = Rgraphum::Parsers::MiserablesParser.new(graph: self)
  end

  def to_graphviz( options={} )
    self.real_aspect! if @aspect == "id"
    default_options = { graph:self, layout: "dot" }
    options = default_options.merge(options)
    dot = Rgraphum::Parsers::GraphvizParser.new( options )
  end

  def to_flare
    self.real_aspect! if @aspect == "id"
    stream = Rgraphum::Parsers::MiserablesParser.new(graph: self)
  end

end
