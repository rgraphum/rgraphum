# -*- coding: utf-8 -*-

# About BA Model
#   The BA Model is a mathematical model of the network with "growth" and "preferential attachment".
#   Growth means that the network is added to vertices with a fixed number of edges one at a time.
#   Preferential attachment shows that the more connected a vertex is, the more likely to receive new edge.
#   An importance of the model is to generate scale-free networks.
#   The consruction of the model is as follows;
#     1st: Select vertices with the probability of each degree / graph's total degree,
#     2nd: Add every selected vertices to new edge.
#     3rd: Repeat the 1st step and the 2nd step until the number of vertices attain the target one.
class Rgraphum::Simulator::BAModel
  def initialize(options={})
    if options[:graph]
      @graph = options[:graph].dup
    else
      @graph = Rgraphum::Graph.new
    end
  end

  # Simurate BAmodel
  # @param [Hash] options BAmodel's options
  # @option options [Graph]   :graph (graph) start(base) origin graph.
  #   default is a graph which used on newly constructing BAModel
  # @option options [Integer] :round (10,000) simurate rounds, this means added vertex size
  # @option options [Integer] :edge_size (1)  edge size on once added a vertex
  # @option options [Integer] :interval  (1)  plus time(min) on new vertex and its edges if vertex or edge has 'cteated_at' value.
  # @option options [Float]   :new_vertex_rate (1.0) Probability of adding new vertex.
  #   If you need to add no new vertex but add edge, use this rate(0.0 - 1.0).
  #   default is 1.0. it means always add new vertex
  # @return [Graph]  a graph after simurate, not same origin graph.
  #
  def simulate(options={})
    default_options = {
      graph: @graph,
      round: 10_000,
      edge_size: 1,
      interval:  1,
      new_vertex_rate: 1.0,
      random_seed: 10,
    }
    options = default_options.merge(options)

    srand options[:random_seed]
    graph = options[:graph]

    base_vertices_size = graph.vertices.size

    while graph.vertices.size - base_vertices_size < options[:round]
      t_v = target_vertex(graph, options[:new_vertex_rate])
      options[:edge_size].times do
        edge = graph.edges.build( { source: source_vertex(graph), target: t_v } )
      end
    end
    graph
  end

  # selecting source vertex method
  #   Propability of BAModel's vertex selection divide
  #   into probability of edges selection and probalility of source or target selection on edge.
  #   And select source vertex
  def source_vertex(graph=@graph)
    return graph.vertices.build({label: new_dummy_label}) if graph.edges.size == 0

    edge_index = rand( graph.edges.size )
    source_vertex = nil
    if rand(2) == 0
      source_vertex = graph.edges[edge_index].source
    else
      source_vertex = graph.edges[edge_index].target
    end
    source_vertex
  end

  # selecting target vertex method
  #   with new_vertex_rate, select new vertex or existing vertex.
  #   if selectiong new vertex, make new vertex and add it on graph
  # @param [Graph] graph (@graph)
  # @param [Float] new_vertex_rate (1.0)
  # @return [Vertex]
  def target_vertex(graph=@graph, new_vertex_rate=1.0)
    vertices = graph.vertices
    if new_vertex_rate < rand and vertices.size > 0
      target_vertex = vertices[rand(vertices.size)]
    else
      graph.vertices.build(label: new_dummy_label)
    end
  end

  # new dummy label method
  def new_dummy_label
    @dummy_label_index ||= 0
    @dummy_labels ||= ("a".."aaaaaa").to_a
    dummy_label = @dummy_labels[@dummy_label_index]
    @dummy_label_index += 1
    dummy_label
  end

  ######################################################################
  # @private
  def vertices_per_min(graph=@graph)
    return nil if graph.vertices.empty?
    first_vertex = graph.vertices.min_by { |vertex| vertex.start }
    last_vertex  = graph.vertices.max_by { |vertex| vertex.start }
    graph.vertices.size / ((last_vertex.start - first_vertex.start) / 60.0)
  end

  def edges_per_min(graph=@graph)
    return nil if graph.edges.empty?
    first_vertex = graph.edges.min_by { |edge| edge.start }
    last_vertex  = graph.edges.max_by { |edge| edge.start }
    graph.edges.size / ((last_vertex.start - first_vertex.start) / 60.0)
  end

  def edges_size_array_per_interval(graph=@graph, interval=1)
    sorted_edges = graph.edges.sort{ |a, b| a.start <=> b.start}
    step = interval * 60

    start_time = sorted_edges[0].start.to_i / step * 60
    end_time   = sorted_edges[-1].start.to_i / step * 60 + 1

    time_array = []
    time = start_time + step
    size = 0
    starts = sorted_edges.map { |edge| edge.start.to_i }

    time, time_array = next_time(starts, time, step, time_array, size)

    time_array
  end

  def next_time(sources, time, step, time_array, size)
    return [time, time_array + [size]] if sources.empty?
    if sources[0] >= time
      time_array << size
      time, time_array = next_time(sources, time+step, step, time_array, 0)
    else
      sources.shift
      time, time_array = next_time(sources, time, step, time_array, size + 1)
    end
  end
end
