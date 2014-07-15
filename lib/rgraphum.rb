# encoding: utf-8

require 'time'

module Rgraphum
  def self.verbose?
    !!ENV['VERBOSE']
  end
end

require_relative 'rgraphum/parsers'
require_relative 'rgraphum/marshal'
require_relative 'rgraphum/simulator'

require_relative 'rgraphum/rgraphum_random'

require_relative 'rgraphum/graph/ids'
require_relative 'rgraphum/graph/elements'
require_relative 'rgraphum/rgraphum_array_dividers'
require_relative 'rgraphum/graph/vertex'
require_relative 'rgraphum/graph/vertices'
require_relative 'rgraphum/graph/edge'
require_relative 'rgraphum/graph/edges'
require_relative 'rgraphum/community'
require_relative 'rgraphum/communities'
require_relative 'rgraphum/graph/element_manager'

require_relative 'rgraphum/graph/math'
require_relative 'rgraphum/graph/gremlin'
require_relative 'rgraphum/importer'
require_relative 'rgraphum/graph'

require_relative 'rgraphum/analyzer'
require_relative 'rgraphum/graph/converter'

require_relative 'rgraphum/t'

require_relative 'rgraphum/graph_builder'

require 'redis'
require 'hiredis'

Redis.current = Redis.new(:driver => :hiredis, :db => 10 )

def new_rgraphum_id
  redis = Redis.current
  redis.incr( "global:RgraphumId" )
end


