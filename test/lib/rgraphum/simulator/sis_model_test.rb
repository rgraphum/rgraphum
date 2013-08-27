# coding: utf-8

require 'test_helper'
require 'rgraphum'

class SISModelTest < MiniTest::Test
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

  def test_initial_si_map
    sis = Rgraphum::Simulator::SISModel.new(graph: @graph)

    assert_equal %w(A B C D E F G H I), sis.vertices.map(&:label)
    assert_equal %w(s s s s s s s s s).map(&:to_sym), sis.si_map
  end

  def test_set_si_map
    si_map = [:s, :i, :s, :i, :s, :i, :s, :i, :s]
    sis = Rgraphum::Simulator::SISModel.new(graph: @graph, si_map: si_map)

    assert_equal %w(A B C D E F G H I), sis.vertices.map(&:label)
    assert_equal %w(s i s i s i s i s).map(&:to_sym), sis.si_map
  end

  def test_infection_rate
    sis = Rgraphum::Simulator::SISModel.new(graph: @graph, infection_rate: 0.5)
    assert_equal 0.5, sis.infection_rate

    assert_raises(ArgumentError) do
      Rgraphum::Simulator::SISModel.new(graph: @graph, infection_rate: -0.1)
    end

    assert_raises(ArgumentError) do
      Rgraphum::Simulator::SISModel.new(graph: @graph, infection_rate: 1.1)
    end
  end

  def test_recovery_rate
    sis = Rgraphum::Simulator::SISModel.new(graph: @graph, recovery_rate: 0.5)
    assert_equal 0.5, sis.recovery_rate

    assert_raises(ArgumentError) do
      Rgraphum::Simulator::SISModel.new(graph: @graph, recovery_rate: -0.1)
    end

    assert_raises(ArgumentError) do
      Rgraphum::Simulator::SISModel.new(graph: @graph, recovery_rate: 1.1)
    end
  end

  def test_zero_periods_simulate
    initial_si_map = [:s, :i, :s, :i, :s, :i, :s, :i, :s]
    sis = Rgraphum::Simulator::SISModel.new(graph: @graph, si_map: initial_si_map)

    sis.simulate periods: 0

    expected_si_map = initial_si_map
    assert_equal expected_si_map, sis.si_map, "si_map should not change"
  end

  def test_infected_1?
    # A -- B -- C    S -- I -- S
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S
    options = {
      graph: @graph,
      si_map: [:s, :i, :s, :i, :s, :i, :s, :i, :s],
      infection_rate: 1.0,
      recovery_rate:  0.0,
    }
    sis = Rgraphum::Simulator::SISModel.new(options)

    v1 = sis.vertices[0]
    assert_equal false, sis.infected?(v1)
    assert_equal false, sis.infected?(v1, 0)
    assert_equal true,  sis.infected?(v1, 1)

    v2 = sis.vertices[1]
    assert_equal true, sis.infected?(v2)
    assert_equal true, sis.infected?(v2, 0)
    assert_equal true, sis.infected?(v2, 1)
  end

  def test_infected_2?
    # A -- B -- C    S -- I -- S
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S
    options = {
      graph: @graph,
      si_map: [:s, :i, :s, :i, :s, :i, :s, :i, :s],
      infection_rate: 0.1,
      recovery_rate:  0.0,
      t_per_period:   0.5,
    }
    sis = Rgraphum::Simulator::SISModel.new(options)

    v1 = sis.vertices[0]
    assert_equal false, sis.infected?(v1, 0)
    assert_equal false, sis.infected?(v1, 1)
    assert_equal false, sis.infected?(v1, 2)
    assert_equal false, sis.infected?(v1, 3)
    assert_equal false, sis.infected?(v1, 9)
    assert_equal true,  sis.infected?(v1, 10)
  end

  def test_susceptible?
    # A -- B -- C    I -- I -- I
    # |    |    |    |    |    |
    # D -- E -- F    I -- I -- I
    # |    |    |    |    |    |
    # G -- H -- I    I -- I -- I
    options = {
      graph: @graph,
      si_map: [:i, :i, :i, :i, :i, :i, :i, :i, :i],
      infection_rate: 0.0,
      recovery_rate:  1.0,
    }
    sis = Rgraphum::Simulator::SISModel.new(options)

    v1 = sis.vertices[0]
    assert_equal false, sis.susceptible?(v1)
    assert_equal false, sis.susceptible?(v1, 0)
    assert_equal true,  sis.susceptible?(v1, 1)
  end

  def test_next_period_only_with_infection_rate
    # A -- B -- C    S -- I -- S
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S
    options = {
      graph: @graph,
      si_map: [:s, :i, :s, :i, :s, :i, :s, :i, :s],
      infection_rate: 0.2,
      recovery_rate:  0.0,
      t_per_period:   1,
    }
    sis = Rgraphum::Simulator::SISModel.new(options)

    # initial state
    # A -- B -- C    S -- I -- S   0    I    0
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I   I    0    I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S   0    I    0
    expected_si_map = [:s, :i, :s, :i, :s, :i, :s, :i, :s]
    assert_equal expected_si_map, sis.si_map, "si_map should not change"

    # 1st period
    # A -- B -- C    S -- I -- S   0.4  I    0.4
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I   I    0.8  I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S   0.4  I    0.4
    sis.next_period
    expected_si_map = [:s, :i, :s, :i, :s, :i, :s, :i, :s]
    assert_equal expected_si_map, sis.si_map, "si_map should not change"

    # 2nd period
    # A -- B -- C    S -- I -- S   0.8  I    0.8
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I   I    I    I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S   0.8  I    0.8
    sis.next_period
    expected_si_map = [:s, :i, :s, :i, :i, :i, :s, :i, :s]
    assert_equal expected_si_map, sis.si_map, "si_map should change"

    # 3rd period
    # A -- B -- C    S -- I -- S   I    I    I
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I   I    I    I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S   I    I    I
    sis.next_period
    expected_si_map = [:i, :i, :i, :i, :i, :i, :i, :i, :i]
    assert_equal expected_si_map, sis.si_map, "si_map should only contain I"

    # 4th period
    # A -- B -- C    S -- I -- S   I    I    I
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I   I    I    I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S   I    I    I
    sis.next_period
    expected_si_map = [:i, :i, :i, :i, :i, :i, :i, :i, :i]
    assert_equal expected_si_map, sis.si_map, "si_map should only contain I"
  end

  def test_next_period_only_with_recovery_rate
    # A -- B -- C    S -- I -- S
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S
    options = {
      graph: @graph,
      si_map: [:s, :i, :s, :i, :s, :i, :s, :i, :s],
      infection_rate: 0,
      recovery_rate:  0.3,
      t_per_period:   1,
    }
    sis = Rgraphum::Simulator::SISModel.new(options)

    # initial state
    # A -- B -- C    S -- I -- S   S    0    S
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I   0    S    0
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S   S    0    S
    expected_si_map = [:s, :i, :s, :i, :s, :i, :s, :i, :s]
    assert_equal expected_si_map, sis.si_map, "si_map should not change"

    # 1st period
    # A -- B -- C    S -- I -- S   S    0.3  S
    # |    |    |    |    |    |              
    # D -- E -- F    I -- S -- I   0.3  S    0.3
    # |    |    |    |    |    |              
    # G -- H -- I    S -- I -- S   S    0.3  S  
    sis.next_period
    expected_si_map = [:s, :i, :s, :i, :s, :i, :s, :i, :s]
    assert_equal expected_si_map, sis.si_map, "si_map should not change"

    # 2nd period
    # A -- B -- C    S -- I -- S   S    0.6  S  
    # |    |    |    |    |    |                
    # D -- E -- F    I -- S -- I   0.6  S    0.6
    # |    |    |    |    |    |                
    # G -- H -- I    S -- I -- S   S    0.6  S
    sis.next_period
    expected_si_map = [:s, :i, :s, :i, :s, :i, :s, :i, :s]
    assert_equal expected_si_map, sis.si_map, "si_map should not change"

    # 3rd period
    # A -- B -- C    S -- I -- S   S    0.9  S  
    # |    |    |    |    |    |                
    # D -- E -- F    I -- S -- I   0.9  S    0.9
    # |    |    |    |    |    |                
    # G -- H -- I    S -- I -- S   S    0.9  S
    sis.next_period
    expected_si_map = [:s, :i, :s, :i, :s, :i, :s, :i, :s]
    assert_equal expected_si_map, sis.si_map, "si_map should not change"

    # 4th period
    # A -- B -- C    S -- I -- S   S    S    S  
    # |    |    |    |    |    |                
    # D -- E -- F    I -- S -- I   S    S    S
    # |    |    |    |    |    |                
    # G -- H -- I    S -- I -- S   S    S    S  
    sis.next_period
    expected_si_map = [:s, :s, :s, :s, :s, :s, :s, :s, :s]
    assert_equal expected_si_map, sis.si_map, "si_map should only contain S"
  end

  def test_next_period_1
    # A -- B -- C    I -- I -- S
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S
    options = {
      graph: @graph,
      si_map: [:i, :i, :s, :i, :s, :i, :s, :i, :s],
      infection_rate: 0.2, # S -> I
      recovery_rate:  0.3, # I -> S
      t_per_period:   1,
    }
    sis = Rgraphum::Simulator::SISModel.new(options)

    # initial state
    # A -- B -- C    I -- I -- S   I0    I0    S0
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I   I0    S0    I0
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S   S0    I0    S0
    expected_si_map = [:i, :i, :s, :i, :s, :i, :s, :i, :s]
    assert_equal expected_si_map, sis.si_map, "si_map should not change"

    # 1st period
    # A -- B -- C    I -- I -- S   I0.3  I0.3  S0.4
    # |    |    |    |    |    |                 
    # D -- E -- F    I -- S -- I   I0.3  S0.8  I0.3
    # |    |    |    |    |    |                 
    # G -- H -- I    S -- I -- S   S0.4  I0.3  S0.4
    sis.next_period
    expected_si_map = [:i, :i, :s, :i, :s, :i, :s, :i, :s]
    assert_equal expected_si_map, sis.si_map, "si_map should not change"

    # 2nd period
    # A -- B -- C    I -- I -- S   I0.6  I0.6  S0.8
    # |    |    |    |    |    |                 
    # D -- E -- F    I -- I -- I   I0.6  I0    I0.6
    # |    |    |    |    |    |                 
    # G -- H -- I    S -- I -- S   S0.8  I0.6  S0.8
    sis.next_period
    expected_si_map = [:i, :i, :s, :i, :i, :i, :s, :i, :s]
    assert_equal expected_si_map, sis.si_map

    # 3rd period
    # A -- B -- C    I -- I -- I   I0.9  I0.9  I0
    # |    |    |    |    |    |                 
    # D -- E -- F    I -- I -- I   I0.9  I0.3  I0.9
    # |    |    |    |    |    |                 
    # G -- H -- I    I -- I -- I   I0    I0.9  I0
    sis.next_period
    expected_si_map = [:i, :i, :i, :i, :i, :i, :i, :i, :i]
    assert_equal expected_si_map, sis.si_map

    # 4th period
    # A -- B -- C    S -- S -- I   S0    S0    I0.3
    # |    |    |    |    |    |                 
    # D -- E -- F    S -- I -- S   S0    I0.6  S0
    # |    |    |    |    |    |                 
    # G -- H -- I    I -- S -- I   I0.3  S0    I0.3
    sis.next_period
    expected_si_map = [:s, :s, :i, :s, :i, :s, :i, :s, :i]
    assert_equal expected_si_map, sis.si_map

    # 5th period
    # A -- B -- C    S -- S -- S   S0    S0.4  I0.6
    # |    |    |    |    |    |                 
    # D -- E -- F    S -- I -- S   S0.4  I0.9  S0.6
    # |    |    |    |    |    |                 
    # G -- H -- I    I -- S -- I   I0.6  S0.6  I0.6
    sis.next_period
    expected_si_map = [:s, :s, :i, :s, :i, :s, :i, :s, :i]
    assert_equal expected_si_map, sis.si_map

    # 6th period
    # A -- B -- C    S -- S -- I   S0    S0.8  I0.9
    # |    |    |    |    |    |                 
    # D -- E -- F    S -- S -- I   S0.8  S0    I0
    # |    |    |    |    |    |                 
    # G -- H -- I    I -- I -- I   I0.9  I0    I0.9
    sis.next_period
    expected_si_map = [:s, :s, :i, :s, :s, :i, :i, :i, :i]
    assert_equal expected_si_map, sis.si_map
  end

  def test_simulate_only_with_infection_rate
    # A -- B -- C    S -- I -- S
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S
    options = {
      graph: @graph,
      si_map: [:s, :i, :s, :i, :s, :i, :s, :i, :s],
      infection_rate: 0.2,
      recovery_rate:  0.0,
      t_per_period:   1,
    }
    sis = Rgraphum::Simulator::SISModel.new(options)

    # initial state
    # A -- B -- C    S -- I -- S   0.4  I    0.4
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I   I    0.8  I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S   0.4  I    0.4
    expected_si_map = [:s, :i, :s, :i, :s, :i, :s, :i, :s]
    assert_equal expected_si_map, sis.si_map, "si_map should not change"

    # 3rd period
    # A -- B -- C    S -- I -- S   I    I    I
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I   I    I    I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S   I    I    I
    sis.simulate periods: 3
    expected_si_map = [:i, :i, :i, :i, :i, :i, :i, :i, :i]
    assert_equal expected_si_map, sis.si_map, "si_map should only contain I"
  end

  def test_simulate_only_with_recovery_rate
    # A -- B -- C    S -- I -- S
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S
    options = {
      graph: @graph,
      si_map: [:s, :i, :s, :i, :s, :i, :s, :i, :s],
      infection_rate: 0,
      recovery_rate:  0.3,
      t_per_period:   1,
    }
    sis = Rgraphum::Simulator::SISModel.new(options)

    # initial state
    # A -- B -- C    S -- I -- S   S    0    S
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I   0    S    0
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S   S    0    S
    expected_si_map = [:s, :i, :s, :i, :s, :i, :s, :i, :s]
    assert_equal expected_si_map, sis.si_map, "si_map should not change"

    # 4th period
    # A -- B -- C    S -- I -- S   S    S    S  
    # |    |    |    |    |    |                
    # D -- E -- F    I -- S -- I   S    S    S
    # |    |    |    |    |    |                
    # G -- H -- I    S -- I -- S   S    S    S  
    sis.simulate periods: 4
    expected_si_map = [:s, :s, :s, :s, :s, :s, :s, :s, :s]
    assert_equal expected_si_map, sis.si_map, "si_map should only contain S"
  end

  def test_simulate
    # A -- B -- C    I -- I -- S
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S
    options = {
      graph: @graph,
      si_map: [:i, :i, :s, :i, :s, :i, :s, :i, :s],
      infection_rate: 0.2, # S -> I
      recovery_rate:  0.3, # I -> S
      t_per_period:   1,
    }
    sis = Rgraphum::Simulator::SISModel.new(options)

    # initial state
    # A -- B -- C    I -- I -- S   I0    I0    S0
    # |    |    |    |    |    |
    # D -- E -- F    I -- S -- I   I0    S0    I0
    # |    |    |    |    |    |
    # G -- H -- I    S -- I -- S   S0    I0    S0
    expected_si_map = [:i, :i, :s, :i, :s, :i, :s, :i, :s]
    assert_equal expected_si_map, sis.si_map, "si_map should not change"

    # 6th period
    # A -- B -- C    S -- S -- I   S0    S0.8  I0.9
    # |    |    |    |    |    |                 
    # D -- E -- F    S -- S -- I   S0.8  S0    I0
    # |    |    |    |    |    |                 
    # G -- H -- I    I -- I -- I   I0.9  I0    I0.9
    sis.simulate periods: 6
    expected_si_map = [:s, :s, :i, :s, :s, :i, :i, :i, :i]
    assert_equal expected_si_map, sis.si_map
  end
end
