#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require_relative '../../lib/rgraphum'
require 'optparse'

module RgraphumSisLifeGame
  include Rgraphum

  def self.run(argv)
    options = build_options(argv)
    periods  = options.delete(:periods)
    row_size = options.delete(:row_size)
    col_size = options.delete(:col_size)
    interval = options.delete(:interval)

    sis = Simulator::SISModel.new(options)

    puts "Row Size: #{row_size}"
    puts "Col Size: #{col_size}"
    puts "Infection rate: #{options[:infection_rate]}"
    puts "Recovery  rate: #{options[:recovery_rate]}"

    sis.simulate(periods: periods) do |period, sis|
      puts_sis_grid_graph sis, period, periods, row_size, col_size
      sleep interval
      reset_cursor row_size unless periods == period
    end
  end

  def self.build_options(argv)
    row_size, col_size = 9, 9
    periods = 10
    infection_rate = 0.2 # S -> I
    recovery_rate  = 0.3 # I -> S
    t_per_period   = 1
    si_pattern = nil
    interval = 1

    argv.clone.options do |opts|
      script_name = File.basename($0)
      opts.banner = "Usage: #{script_name} [options]"

      opts.separator ""

      opts.on("--size=SIZExSIZE",  'Row x Col size ex) 9x9') { |v| row_size, col_size = v.split("x").map(&:to_i) }
      opts.on("--periods=Periods", 'Periods',  Integer) { |v| periods  = v.to_i }
      opts.on("--infection-rate=RATE", 'Infection rate', Float) { |v| infection_rate = v.to_f }
      opts.on("--recovery-rate=RATE",  'Recovery rate',  Float) { |v| recovery_rate  = v.to_f }
      opts.on("--si-pattern=PATTERN",  'Pattern string line like "SISIS" or "isis"') { |v| si_pattern  = v }
      opts.on("--interval=SECONDS",    'Animation interval in [S]: default 1.0', Float) { |v| interval  = v.to_f }

      opts.separator ""

      opts.separator "ex)"
      opts.separator "  ./examples/sis_model/lifegame.rb --size=50x100 --periods=1000 --interval=0.2 --si-pattern=ssiiiss"
      opts.separator ""

      opts.on("-h", "--help", "Show this help message.") { $stdout.puts opts; exit }

      opts.parse!
    end

    graph = build_grid_graph(row_size, col_size)

    if si_pattern
      si_pattern = si_pattern.downcase.split(//).map(&:to_sym)
      k = 0
      si_map = row_size.times.map do |i|
        col_size.times.map do |j|
          si = si_pattern[k]
          k = (k + 1) % si_pattern.size
          si
        end
      end
    else
      si_map = row_size.times.map do |i|
        col_size.times.map do |j|
          if i.even?
            j.even? ? :s : :i
          else
            j.even? ? :i : :s
          end
        end
      end
    end
    si_map.flatten!

    {
      graph: graph,
      si_map: si_map,
      infection_rate: infection_rate, # S -> I
      recovery_rate:  recovery_rate,  # I -> S
      t_per_period:   t_per_period,

      row_size: row_size,
      col_size: col_size,
      periods:  periods,
      interval: interval,
    }
  end

  def self.build_grid_graph(row_size, col_size)
    graph = Graph.new

    row_size.times do |i|
      col_size.times do |j|
        graph.vertices.build(label: "#{i}-#{j}")
      end
    end

    row_size.times do |i|
      (1...col_size).each do |j|
        source_vertex = graph.vertices[i * col_size + j - 1]
        target_vertex = graph.vertices[i * col_size + j]
        graph.edges.build(source: source_vertex, target: target_vertex)
      end
    end

    (1...row_size).each do |i|
      col_size.times do |j|
        source_vertex = graph.vertices[(i - 1) * col_size + j]
        target_vertex = graph.vertices[(i)     * col_size + j]
        graph.edges.build(source: source_vertex, target: target_vertex)
      end
    end

    graph
  end

  def self.reset_cursor(row_size)
    magic_str = "\r"
    (row_size+2).times do
      magic_str += "\e[1A"
    end
    print magic_str
  end

  def self.puts_sis_grid_graph(sis, period, periods, row_size, col_size)
    si_map = sis.si_map

    puts " Priod: %4d/%4d ----------------------         " % [period, periods]
    row_size.times do |i|
      line = "  "
      col_size.times do |j|
        si = si_map[i * col_size + j]
        case si
        when :i
          line += "\e[31mI"
        when :s
          line += "\e[32mS"
        end
        line += "\e[0m "
      end
      puts line
    end
    puts "----------------------------------------"
  end
end

RgraphumSisLifeGame.run(ARGV)
