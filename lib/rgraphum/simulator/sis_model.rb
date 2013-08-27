# -*- coding: utf-8 -*-

# SIS Model
#   Susceptible Infected Susceptible Model
#
class Rgraphum::Simulator::SISModel
  attr_reader :graph
  attr_reader :recovery_rate, :infection_rate

  # options: Options Hash
  #   graph:   Graph instance
  #   si_map: Array of symbol(:s or :i)
  #   infection_rate: λ 0 <= λ <= 1
  #   recovery_rate:  μ 0 <= μ <= 1
  #   periods:        0 <=
  #   t_per_period:   increase t for each period
  #
  def initialize(options={})
    @graph = options[:graph]

    @t_map = Hash.new(0)

    @si_map = {}
    if options[:si_map]
      if @graph.vertices.size != options[:si_map].size
        raise ArgumentError, ":si_map should be same size with graph.vertices"
      end
      options[:si_map].each_with_index do |si, index|
        vertex = @graph.vertices[index]
        unless [:s, :i].include?(si)
          raise ArgumentError, ":si_map can only have :s or :i"
        end
        @si_map[vertex.id] = si
      end
    else
      @graph.vertices.each do |vertex|
        @si_map[vertex.id] = :s
      end
    end

    if options[:infection_rate]
      @infection_rate = options[:infection_rate].to_f
      if @infection_rate < 0 || 1 < @infection_rate
        raise ArgumentError, ":infection_rate should be between 0 and 1"
      end
    else
      # raise ArgumentError, ":infection_rate is required"
    end

    if options[:recovery_rate]
      @recovery_rate = options[:recovery_rate].to_f
      if @recovery_rate < 0 || 1 < @recovery_rate
        raise ArgumentError, ":recovery_rate should be between 0 and 1"
      end
    else
      # raise ArgumentError, ":recovery_rate is required"
    end

    if options[:periods]
      @periods = options[:periods].to_i
      if 0 > @periods
        raise ArgumentError, ":periods should be greater than equal 0"
      end
    end

    if options[:t_per_period]
      @t_per_period = options[:t_per_period].to_f
      if 0 > @t_per_period
        raise ArgumentError, ":t_per_period should be greater than equal 0"
      end
    else
      @t_per_period = 1
    end
  end

  # Simurate SIS Model
  def simulate(options={})
    periods = options[:periods].to_i
    yield 0, self if block_given?
    periods.times do |n|
      next_period
      yield n+1, self if block_given?
    end
  end

  def vertices
    @graph.vertices
  end

  def edges
    @graph.edges
  end

  def next_period
    new_si_map = {}
    new_t_map  = {}

    @graph.vertices.each do |vertex|
      vertex_id = vertex.id
      case @si_map[vertex_id]
      when :i
        if susceptible?(vertex, 1)
          new_si_map[vertex_id] = :s
          new_t_map[vertex_id] = 0
        else
          new_si_map[vertex_id] = :i
          new_t_map[vertex_id] = @t_map[vertex_id] + @t_per_period
        end
      when :s
        if infected?(vertex, 1)
          new_si_map[vertex_id] = :i
          new_t_map[vertex_id] = 0
        else
          new_si_map[vertex_id] = :s
          new_t_map[vertex_id] = @t_map[vertex_id] + @t_per_period
        end
      end
    end

    @si_map = new_si_map
    @t_map  = new_t_map
  end

  def infected?(vertex, periods=0)
    return true  if @si_map[vertex.id] == :i
    return false if periods.zero?

    t = @t_map[vertex.id] + @t_per_period * periods

    num_infected = vertex.both.inject(0) { |num_infected, v|
      num_infected + (@si_map[v.id] == :i ? 1 : 0)
    }

    if 1 <= num_infected * infection_rate * t
      true
    else
      false
    end
  end

  def susceptible?(vertex, periods=0)
    return true  if @si_map[vertex.id] == :s
    return false if periods.zero?

    t = @t_map[vertex.id] + @t_per_period * periods

    if 1 <= recovery_rate * t
      true
    else
      false
    end
  end

  # SI(:s or :i) array, order is the same as vertices
  def si_map
    @si_map.values
  end
end
