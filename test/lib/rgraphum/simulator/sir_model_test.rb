# coding: utf-8

require 'test_helper'
require 'rgraphum'

class SIRModelTest < MiniTest::Unit::TestCase
  def setup
    # A -- B -- C
    # |    |    |
    # D -- E -- F
    # |    |    |
    # G -- H -- I
    v = {}
    @graph = Rgraphum::Graph.new
    v[:a] = @graph.vertices.build(label: "A")
    v[:b] = @graph.vertices.build(label: "B")
    v[:c] = @graph.vertices.build(label: "C")
    v[:d] = @graph.vertices.build(label: "D")
    v[:e] = @graph.vertices.build(label: "E")
    v[:f] = @graph.vertices.build(label: "F")
    v[:g] = @graph.vertices.build(label: "G")
    v[:h] = @graph.vertices.build(label: "H")
    v[:i] = @graph.vertices.build(label: "I")

    @graph.edges.build(source: v[:a], target: v[:b])
    @graph.edges.build(source: v[:b], target: v[:c])
    @graph.edges.build(source: v[:a], target: v[:d])
    @graph.edges.build(source: v[:b], target: v[:e])
    @graph.edges.build(source: v[:c], target: v[:f])
    @graph.edges.build(source: v[:d], target: v[:e])
    @graph.edges.build(source: v[:e], target: v[:f])
    @graph.edges.build(source: v[:d], target: v[:g])
    @graph.edges.build(source: v[:e], target: v[:h])
    @graph.edges.build(source: v[:f], target: v[:i])
    @graph.edges.build(source: v[:g], target: v[:h])
    @graph.edges.build(source: v[:h], target: v[:i])
  end

  def test_initial_sir_map
    sir = Rgraphum::Simulator::SIRModel.new(graph: @graph)

    assert_equal %w(A B C D E F G H I), sir.vertices.map(&:label)
    assert_equal %w(s s s s s s s s s).map(&:to_sym), sir.sir_map
  end

  def test_set_sir_map
    sir_map = [:s, :i, :s, :i, :s, :i, :s, :i, :s]
    sir = Rgraphum::Simulator::SIRModel.new(graph: @graph, sir_map: sir_map)

    assert_equal %w(A B C D E F G H I), sir.vertices.map(&:label)
    assert_equal %w(s i s i s i s i s).map(&:to_sym), sir.sir_map
  end

  def test_infection_rate
    sir = Rgraphum::Simulator::SIRModel.new(graph: @graph, infection_rate: 0.5)
    assert_equal 0.5, sir.infection_rate

    assert_raises(ArgumentError) do
      Rgraphum::Simulator::SIRModel.new(graph: @graph, infection_rate: -0.1)
    end

    assert_raises(ArgumentError) do
      Rgraphum::Simulator::SIRModel.new(graph: @graph, infection_rate: 1.1)
    end
  end

  def test_recovery_rate
    sir = Rgraphum::Simulator::SIRModel.new(graph: @graph, recovery_rate: 0.5)
    assert_equal 0.5, sir.recovery_rate

    assert_raises(ArgumentError) do
      Rgraphum::Simulator::SIRModel.new(graph: @graph, recovery_rate: -0.1)
    end

    assert_raises(ArgumentError) do
      Rgraphum::Simulator::SIRModel.new(graph: @graph, recovery_rate: 1.1)
    end
  end

  def test_zero_periods_simulate
    initial_sir_map = [:s, :i, :s, :i, :s, :i, :s, :i, :s]
    sir = Rgraphum::Simulator::SIRModel.new(graph: @graph, sir_map: initial_sir_map)

    sir.simulate periods: 0

    expected_sir_map = initial_sir_map
    assert_equal expected_sir_map, sir.sir_map, "sir_map should not change"
  end

  def test_infected_1?
    # A -- B -- C    S -- I -- S
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S
    options = {
      graph: @graph,
      sir_map: [:s, :i, :s, :i, :s, :i, :s, :i, :s],
      infection_rate: 1.0,
      recovery_rate:  0.0,
    }
    sir = Rgraphum::Simulator::SIRModel.new(options)

    v1 = sir.vertices[0]
    assert_equal false, sir.infected?(v1)
    assert_equal false, sir.infected?(v1, 0)
    assert_equal true,  sir.infected?(v1, 1)

    v2 = sir.vertices[1]
    assert_equal true, sir.infected?(v2)
    assert_equal true, sir.infected?(v2, 0)
    assert_equal true, sir.infected?(v2, 1)
  end

  def test_infected_2?
    # A -- B -- C    S -- I -- S
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S
    options = {
      graph: @graph,
      sir_map: [:s, :i, :s, :i, :s, :i, :s, :i, :s],
      infection_rate: 0.1,
      recovery_rate:  0.0,
      t_per_period:   0.5,
    }
    sir = Rgraphum::Simulator::SIRModel.new(options)

    v1 = sir.vertices[0]
    assert_equal false, sir.infected?(v1, 0)
    assert_equal false, sir.infected?(v1, 1)
    assert_equal false, sir.infected?(v1, 2)
    assert_equal false, sir.infected?(v1, 3)
    assert_equal false, sir.infected?(v1, 9)
    assert_equal true,  sir.infected?(v1, 10)
  end

  def test_recovered?
    # A -- B -- C    I -- I -- I
    # |    |    |    |    |    |
    # D -- E -- F    I -- I -- I
    # |    |    |    |    |    |
    # G -- H -- I    I -- I -- I
    options = {
      graph: @graph,
      sir_map: [:i, :i, :i, :i, :i, :i, :i, :i, :i],
      infection_rate: 0.0,
      recovery_rate:  1.0,
    }
    sir = Rgraphum::Simulator::SIRModel.new(options)

    v1 = sir.vertices[0]
    assert_equal false, sir.recovered?(v1)
    assert_equal false, sir.recovered?(v1, 0)
    assert_equal true,  sir.recovered?(v1, 1)
  end

  # def test_susceptible?
  #   # A -- B -- C    S -- I -- I
  #   # |    |    |    |    |    |
  #   # D -- E -- F    I -- I -- I
  #   # |    |    |    |    |    |
  #   # G -- H -- I    I -- I -- I
  #   options = {
  #     graph: @graph,
  #     sir_map: [:s, :i, :i, :i, :i, :i, :i, :i, :i],
  #     infection_rate: 1.0,
  #     recovery_rate:  0.0,
  #   }
  #   sir = Rgraphum::Simulator::SIRModel.new(options)

  #   v1 = sir.vertices[0]
  #   assert_equal true,  sir.susceptible?(v1)
  #   assert_equal true,  sir.susceptible?(v1, 0)
  #   assert_equal false, sir.susceptible?(v1, 1)

  #   v2 = sir.vertices[1]
  #   assert_equal false, sir.susceptible?(v2)
  #   assert_equal false, sir.susceptible?(v2, 0)
  #   assert_equal false, sir.susceptible?(v2, 1)
  # end

  def test_next_period_only_with_infection_rate
    # A -- B -- C    S -- I -- S
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S
    options = {
      graph: @graph,
      sir_map: [:s, :i, :s, :i, :s, :i, :s, :i, :s],
      infection_rate: 0.2,
      recovery_rate:  0.0,
      t_per_period:   1,
    }
    sir = Rgraphum::Simulator::SIRModel.new(options)

    # initial state
    # A -- B -- C    S -- I -- S   0    I    0
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I   I    0    I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S   0    I    0
    expected_sir_map = [:s, :i, :s, :i, :s, :i, :s, :i, :s]
    assert_equal expected_sir_map, sir.sir_map, "sir_map should not change"

    # 1st period
    # A -- B -- C    S -- I -- S   0.4  I    0.4
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I   I    0.8  I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S   0.4  I    0.4
    sir.next_period
    expected_sir_map = [:s, :i, :s, :i, :s, :i, :s, :i, :s]
    assert_equal expected_sir_map, sir.sir_map, "sir_map should not change"

    # 2nd period
    # A -- B -- C    S -- I -- S   0.8  I    0.8
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I   I    I    I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S   0.8  I    0.8
    sir.next_period
    expected_sir_map = [:s, :i, :s, :i, :i, :i, :s, :i, :s]
    assert_equal expected_sir_map, sir.sir_map, "sir_map should change"

    # 3rd period
    # A -- B -- C    S -- I -- S   I    I    I
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I   I    I    I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S   I    I    I
    sir.next_period
    expected_sir_map = [:i, :i, :i, :i, :i, :i, :i, :i, :i]
    assert_equal expected_sir_map, sir.sir_map, "sir_map should only contain I"

    # 4th period
    # A -- B -- C    S -- I -- S   I    I    I
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I   I    I    I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S   I    I    I
    sir.next_period
    expected_sir_map = [:i, :i, :i, :i, :i, :i, :i, :i, :i]
    assert_equal expected_sir_map, sir.sir_map, "sir_map should only contain I"
  end

  def test_next_period_only_with_recovery_rate
    # A -- B -- C    S -- I -- S
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S
    options = {
      graph: @graph,
      sir_map: [:s, :i, :s, :i, :s, :i, :s, :i, :s],
      infection_rate: 0,
      recovery_rate:  0.3,
      t_per_period:   1,
    }
    sir = Rgraphum::Simulator::SIRModel.new(options)

    # initial state
    # A -- B -- C    S -- I -- S   S    0    S
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I   0    S    0
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S   S    0    S
    expected_sir_map = [:s, :i, :s, :i, :s, :i, :s, :i, :s]
    assert_equal expected_sir_map, sir.sir_map, "sir_map should not change"

    # 1st period
    # A -- B -- C    S -- I -- S   S    0.3  S
    # |    |    |    |    |    |              
    # D -- E -- F    I -- S -- I   0.3  S    0.3
    # |    |    |    |    |    |              
    # G -- H -- I    S -- I -- S   S    0.3  S  
    sir.next_period
    expected_sir_map = [:s, :i, :s, :i, :s, :i, :s, :i, :s]
    assert_equal expected_sir_map, sir.sir_map, "sir_map should not change"

    # 2nd period
    # A -- B -- C    S -- I -- S   S    0.6  S  
    # |    |    |    |    |    |                
    # D -- E -- F    I -- S -- I   0.6  S    0.6
    # |    |    |    |    |    |                
    # G -- H -- I    S -- I -- S   S    0.6  S
    sir.next_period
    expected_sir_map = [:s, :i, :s, :i, :s, :i, :s, :i, :s]
    assert_equal expected_sir_map, sir.sir_map, "sir_map should not change"

    # 3rd period
    # A -- B -- C    S -- I -- S   S    0.9  S  
    # |    |    |    |    |    |                
    # D -- E -- F    I -- S -- I   0.9  S    0.9
    # |    |    |    |    |    |                
    # G -- H -- I    S -- I -- S   S    0.9  S
    sir.next_period
    expected_sir_map = [:s, :i, :s, :i, :s, :i, :s, :i, :s]
    assert_equal expected_sir_map, sir.sir_map, "sir_map should not change"

    # 4th period
    # A -- B -- C    S -- I -- S   S    R    S  
    # |    |    |    |    |    |                
    # D -- E -- F    I -- S -- I   R    S    R
    # |    |    |    |    |    |                
    # G -- H -- I    S -- I -- S   S    R    S
    sir.next_period
    expected_sir_map = [:s, :r, :s, :r, :s, :r, :s, :r, :s]
    assert_equal expected_sir_map, sir.sir_map, "sir_map should only contain S"
  end

  def test_next_period_1
    # A -- B -- C    I -- I -- S
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S
    options = {
      graph: @graph,
      sir_map: [:i, :i, :s, :i, :s, :i, :s, :i, :s],
      infection_rate: 0.2, # S -> I
      recovery_rate:  0.3, # I -> S
      t_per_period:   1,
    }
    sir = Rgraphum::Simulator::SIRModel.new(options)

    # initial state
    # A -- B -- C    I -- I -- S   I0    I0    S0
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I   I0    S0    I0
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S   S0    I0    S0
    expected_sir_map = [:i, :i, :s, :i, :s, :i, :s, :i, :s]
    assert_equal expected_sir_map, sir.sir_map, "sir_map should not change"

    # 1st period
    # A -- B -- C    I -- I -- S   I0.3  I0.3  S0.4
    # |    |    |    |    |    |                 
    # D -- E -- F    I -- S -- I   I0.3  S0.8  I0.3
    # |    |    |    |    |    |                 
    # G -- H -- I    S -- I -- S   S0.4  I0.3  S0.4
    sir.next_period
    expected_sir_map = [:i, :i, :s, :i, :s, :i, :s, :i, :s]
    assert_equal expected_sir_map, sir.sir_map, "sir_map should not change"

    # 2nd period
    # A -- B -- C    I -- I -- S   I0.6  I0.6  S0.8
    # |    |    |    |    |    |                 
    # D -- E -- F    I -- I -- I   I0.6  I0    I0.6
    # |    |    |    |    |    |                 
    # G -- H -- I    S -- I -- S   S0.8  I0.6  S0.8
    sir.next_period
    expected_sir_map = [:i, :i, :s, :i, :i, :i, :s, :i, :s]
    assert_equal expected_sir_map, sir.sir_map

    # 3rd period
    # A -- B -- C    I -- I -- I   I0.9  I0.9  I0
    # |    |    |    |    |    |                 
    # D -- E -- F    I -- I -- I   I0.9  I0.3  I0.9
    # |    |    |    |    |    |                 
    # G -- H -- I    I -- I -- I   I0    I0.9  I0
    sir.next_period
    expected_sir_map = [:i, :i, :i, :i, :i, :i, :i, :i, :i]
    assert_equal expected_sir_map, sir.sir_map

    # 4th period
    # A -- B -- C    S -- S -- I   R     R     I0.3
    # |    |    |    |    |    |                 
    # D -- E -- F    S -- I -- S   R     I0.6  R
    # |    |    |    |    |    |                 
    # G -- H -- I    I -- S -- I   I0.3  R     I0.3
    sir.next_period
    expected_sir_map = [:r, :r, :i, :r, :i, :r, :i, :r, :i]
    assert_equal expected_sir_map, sir.sir_map

    # 5th period
    # A -- B -- C    S -- S -- S   R     R     I0.6
    # |    |    |    |    |    |                 
    # D -- E -- F    S -- I -- S   R     I0.9  R
    # |    |    |    |    |    |                 
    # G -- H -- I    I -- S -- I   I0.6  R     I0.6
    sir.next_period
    expected_sir_map = [:r, :r, :i, :r, :i, :r, :i, :r, :i]
    assert_equal expected_sir_map, sir.sir_map

    # 6th period
    # A -- B -- C    S -- S -- I   R     R     I0.9
    # |    |    |    |    |    |                 
    # D -- E -- F    S -- S -- I   R     R     R
    # |    |    |    |    |    |                 
    # G -- H -- I    I -- I -- I   I0.9  R     I0.9
    sir.next_period
    expected_sir_map = [:r, :r, :i, :r, :r, :r, :i, :r, :i]
    assert_equal expected_sir_map, sir.sir_map

    # 7th period
    # A -- B -- C    S -- S -- I   R     R     R
    # |    |    |    |    |    |                 
    # D -- E -- F    S -- S -- I   R     R     R
    # |    |    |    |    |    |                 
    # G -- H -- I    I -- I -- I   R     R     R
    sir.next_period
    expected_sir_map = [:r, :r, :r, :r, :r, :r, :r, :r, :r]
    assert_equal expected_sir_map, sir.sir_map
  end

  def test_simulate_only_with_infection_rate
    # A -- B -- C    S -- I -- S
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S
    options = {
      graph: @graph,
      sir_map: [:s, :i, :s, :i, :s, :i, :s, :i, :s],
      infection_rate: 0.2,
      recovery_rate:  0.0,
      t_per_period:   1,
    }
    sir = Rgraphum::Simulator::SIRModel.new(options)

    # initial state
    # A -- B -- C    S -- I -- S   0.4  I    0.4
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I   I    0.8  I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S   0.4  I    0.4
    expected_sir_map = [:s, :i, :s, :i, :s, :i, :s, :i, :s]
    assert_equal expected_sir_map, sir.sir_map, "sir_map should not change"

    # 3rd period
    # A -- B -- C    S -- I -- S   I    I    I
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I   I    I    I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S   I    I    I
    sir.simulate periods: 3
    expected_sir_map = [:i, :i, :i, :i, :i, :i, :i, :i, :i]
    assert_equal expected_sir_map, sir.sir_map, "sir_map should only contain I"
  end

  def test_simulate_only_with_recovery_rate
    # A -- B -- C    S -- I -- S
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S
    options = {
      graph: @graph,
      sir_map: [:s, :i, :s, :i, :s, :i, :s, :i, :s],
      infection_rate: 0,
      recovery_rate:  0.3,
      t_per_period:   1,
    }
    sir = Rgraphum::Simulator::SIRModel.new(options)

    # initial state
    # A -- B -- C    S -- I -- S   S    I    S
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I   I    S    I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S   S    I    S
    expected_sir_map = [:s, :i, :s, :i, :s, :i, :s, :i, :s]
    assert_equal expected_sir_map, sir.sir_map, "sir_map should not change"

    # 4th period
    # A -- B -- C    S -- I -- S   S    R    S  
    # |    |    |    |    |    |                
    # D -- E -- F    I -- S -- I   R    S    R
    # |    |    |    |    |    |                
    # G -- H -- I    S -- I -- S   S    R    S  
    sir.simulate periods: 4
    expected_sir_map = [:s, :r, :s, :r, :s, :r, :s, :r, :s]
    assert_equal expected_sir_map, sir.sir_map, "sir_map should only contain S"
  end

  def test_simulate
    # A -- B -- C    I -- I -- S
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S
    options = {
      graph: @graph,
      sir_map: [:i, :i, :s, :i, :s, :i, :s, :i, :s],
      infection_rate: 0.2, # S -> I
      recovery_rate:  0.3, # I -> S
      t_per_period:   1,
    }
    sir = Rgraphum::Simulator::SIRModel.new(options)

    # initial state
    # A -- B -- C    I -- I -- S   I0    I0    S0
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I   I0    S0    I0
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S   S0    I0    S0
    expected_sir_map = [:i, :i, :s, :i, :s, :i, :s, :i, :s]
    assert_equal expected_sir_map, sir.sir_map, "sir_map should not change"

    # 6th period
    # A -- B -- C    S -- S -- I   R     R     I
    # |    |    |    |    |    |                 
    # D -- E -- F    S -- S -- I   R     R     R
    # |    |    |    |    |    |                 
    # G -- H -- I    I -- I -- I   I     R     I
    sir.simulate periods: 6
    expected_sir_map = [:r, :r, :i, :r, :r, :r, :i, :r, :i]
    assert_equal expected_sir_map, sir.sir_map
  end
end
