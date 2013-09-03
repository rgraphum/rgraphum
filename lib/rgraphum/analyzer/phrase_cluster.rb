# -*- coding: utf-8 -*-

class Rgraphum::PhraseCluster
  include Enumerable

  def initialize(*paths)
    if paths.empty?
      @paths = {}
    else
      @paths = Hash[paths.map { |path| [path.end_vertex.id, path] }]
    end
  end

  def paths
    @paths.values
  end

  def each_path
    if block_given?
      @paths.each do |id, path|
        yield path
      end
    else
      to_enum
    end
  end

  def add_path(path)
    @paths[path.end_vertex.id] = path
  end

  def find_path(end_vertex_id)
    @paths[end_vertex_id]
  end

  def append_vertex(path, vertex)
    @paths[path.end_vertex.id].vertices << vertex
  end

  def empty?
    @paths.empty?
  end

  def have_vertex_in_path?(end_vertex, vertex)
    path = find_path(end_vertex.id)
    return unless path
    path.vertices.include?(vertex)
  end

  def have_vertex?(vertex)
    @paths.any? do |id, path|
      path.vertices.include?(vertex)
    end
  end

  def have_end_vertex?(end_vertex)
    @paths.any? { |id, path| path.end_vertex.id == (end_vertex.id rescue end_vertex) }
  end

  def to_hash
    hash = {}
    @paths.each do |id, path|
      hash[path.end_vertex] = path.vertices
    end
    hash
  end
end
