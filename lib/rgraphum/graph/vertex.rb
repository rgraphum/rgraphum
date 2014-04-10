# -*- coding: utf-8 -*-

def Rgraphum::Vertex(hash_or_vertex)
  if hash_or_vertex.instance_of?(Rgraphum::Vertex)
    hash_or_vertex
  else
    Rgraphum::Vertex.new(hash_or_vertex)
  end
end

class Rgraphum::Vertex < Hash
  attr_accessor :graph

  def initialize(fields={})
    unless fields.empty?
      unknown_fields = fields.keys - @@field_names
      unless unknown_fields.empty?
        raise ArgumentError, "No such field(s) in Vertex: #{unknown_fields.join(', ')}"
      end
      fields.each do |name, value|
        self.send("#{name}=", value)
      end
    end
    @edges = Rgraphum::Edges.new
    @in_edges = Rgraphum::Edges.new
    @out_edges = Rgraphum::Edges.new

    @edges.vertex = self
  end

  # Gremlin: inE
  #
  # Gets the incoming edges of the vertex.
  #
  #     gremlin> v = g.v(4)
  #     ==>v[4]
  #     gremlin> v.inE.outV
  #     ==>v[1]
  #     gremlin> v.in
  #     ==>v[1]
  #     gremlin> v = g.v(3)
  #     ==>v[3]
  #     gremlin> v.in("created")
  #     ==>v[1]
  #     ==>v[4]
  #     ==>v[6]
  #     gremlin> v.inE("created").outV
  #     ==>v[1]
  #     ==>v[4]
  #     ==>v[6]
  #
  def inE(*key)
    find_edges(key, :in)
  end
  alias :in_e :inE

  # Gremlin: outE
  #
  # Gets the outgoing edges to the vertex.
  #
  #     gremlin> v = g.v(1)
  #     ==>v[1]
  #     gremlin> v.outE.inV
  #     ==>v[2]
  #     ==>v[4]
  #     ==>v[3]
  #     gremlin> v.out
  #     ==>v[2]
  #     ==>v[4]
  #     ==>v[3]
  #     gremlin> v.outE('knows').inV
  #     ==>v[2]
  #     ==>v[4]
  #     gremlin> v.out('knows')
  #     ==>v[2]
  #     ==>v[4]
  #

  def outE(*key)
    find_edges(key, :out)
  end
  alias :out_e :outE

  # Gremlin: bothE
  #
  # Get both incoming and outgoing edges of the vertex.
  #
  #     gremlin> v = g.v(4)
  #     ==>v[4]
  #     gremlin> v.bothE
  #     ==>e[8][1-knows->4]
  #     ==>e[10][4-created->5]
  #     ==>e[11][4-created->3]
  #     gremlin> v.bothE('knows')
  #     ==>e[8][1-knows->4]
  #     gremlin> v.bothE('knows', 'created')
  #     ==>e[8][1-knows->4]
  #     ==>e[10][4-created->5]
  #     ==>e[11][4-created->3]
  #
  def bothE(*key)
    find_edges(key, :both)
  end
  alias :both_e :bothE

  # Gremlin: in
  #
  # Gets the adjacent vertices to the vertex.
  #
  #     gremlin> v = g.v(4)
  #     ==>v[4]
  #     gremlin> v.inE.outV
  #     ==>v[1]
  #     gremlin> v.in
  #     ==>v[1]
  #     gremlin> v = g.v(3)
  #     ==>v[3]
  #     gremlin> v.in("created")
  #     ==>v[1]
  #     ==>v[4]
  #     ==>v[6]
  #     gremlin> v.inE("created").outV
  #     ==>v[1]
  #     ==>v[4]
  #     ==>v[6]
  #
  def in(*key)
    find_vertices(key, :in)
  end

  # Gremlin: out
  #
  # Gets the out adjacent vertices to the vertex.
  #
  #     gremlin> v = g.v(1)
  #     ==>v[1]
  #     gremlin> v.outE.inV
  #     ==>v[2]
  #     ==>v[4]
  #     ==>v[3]
  #     gremlin> v.out
  #     ==>v[2]
  #     ==>v[4]
  #     ==>v[3]
  #     gremlin> v.outE('knows').inV
  #     ==>v[2]
  #     ==>v[4]
  #     gremlin> v.out('knows')
  #     ==>v[2]
  #     ==>v[4]
  #
  def out(*key)
    find_vertices(key, :out)
  end

  # Gremlin: both
  #
  # Get both adjacent vertices of the vertex, the in and the out.
  #
  #     gremlin> v = g.v(4)
  #     ==>v[4]
  #     gremlin> v.both
  #     ==>v[1]
  #     ==>v[5]
  #     ==>v[3]
  #     gremlin> v.both('knows')
  #     ==>v[1]
  #     gremlin> v.both('knows', 'created')
  #     ==>v[1]
  #     ==>v[5]
  #     ==>v[3]
  #
  def both(*key)
    find_vertices(key, :both)
  end


  # Non-Gremlin methods

  def dup
    super.tap { |vertex|
      vertex.graph = nil
      vertex.edges = @edges.dup
      vertex.edges.vertex = vertex

      vertex.edges.each do |edge|
        if edge.source.equal?(self)
          edge.source = vertex
        end
        if edge.target.equal?(self)
          edge.target = vertex
        end
      end
    }
  end

  def edges
    @edges
  end

  def in_edges
    @in_edges
  end

  def out_edges
    @out_edges
  end

  def find_edges(labels=[], direction=:both)
    case direction
    when :in
      results = @edges.where(target: self).all
#      results = @in_edges
    when :out
      results = @edges.where(source: self).all
#      results = @out_edges
    else # :both
      results = @edges
    end

    if labels.empty?
      Rgraphum::Edges(results)
    else
      found_edges = results.find_all { |edge| labels.include?(edge.label) }
      Rgraphum::Edges(found_edges)
    end
  end

  def find_vertices(labels=[], direction=:both)
    case direction
    when :in
      vertices = find_edges(labels, :in).map(&:source)
    when :out
      vertices = find_edges(labels, :out).map(&:target)
    else # :both
      vertices  = find_edges(labels, :in).map(&:source)
      vertices += find_edges(labels, :out).map(&:target)
    end
    Rgraphum::Vertices(vertices)
  end

  def neighborhoods
    raise NotImplementedError
  end

  def edges=(array)
    return unless array.is_a?(Array)
    @edges = Rgraphum::Edges(array)
    @edges.vertex = self
    @edges
  end

  def inter_edges
    []
  end

  def clear_cache
    @degree = nil
    @degree_weight = nil
  end

  def degree
    @degree ||= @edges.size
  end

  def degree_weight
    @degree_weight ||= @edges.inject(0) { |sum, edge| sum + (edge.weight || 1.0) }
  end

  def sigma_tot
    self.degree_weight
  end

  def sigma_in
    0
  end

  # chech self and another have alive on sama term
  def within_term(another)
    return false unless self.start < another.start
    return false unless another.start < self.end
    true
  end
  
  def start_root_vertex?
    return true if self.in.empty?
    false
  end
  
  def end_root_vertex?
    return true if self.out.empty?
    false 
  end
  
  # accessors

  # attr_accessor :id
  # attr_accessor :source, :target
  # attr_accessor :start,  :end
  # attr_accessor :label
  # attr_accessor :count
  # attr_accessor :attvalues
  # attr_accessor :community
  # attr_accessor :edges
  # attr_accessor :words

  def [](key)
    send(key)
  end

  def []=(key, value)
    send("#{key}=")
  end

  def ==(other)
    if other.is_a?(Rgraphum::Vertex)
      return false unless id == other.id
    else
      return id == other
    end
    return false unless edges == other.edges
    true
  end

  def to_hash
    hash = {}
    @@field_names.each do |name|
      value = instance_variable_get("@#{name}")
      if value
        if value.respond_to?(:to_hash)
          hash[name] = value.to_hash
        else
          hash[name] = value
        end
      end
    end
    hash
  end

  def to_s
    to_hash.to_s
  end

  # FIXME
  def self.field(*field_names)
    @@field_names ||= []
    field_names = [field_names] unless field_names.is_a?(Array)
    field_names.each do |field_name|
      @@field_names << field_name.to_sym
      class_eval <<-EOT, __FILE__, __LINE__ + 1
        def #{field_name}
          # self[:#{field_name}]
          @#{field_name}
        end
        def #{field_name}=(rhs)
          # self[:#{field_name}] = rhs if respond_to?(:[]=) # FIXME
          @#{field_name} = rhs
        end
       EOT
    end
  end

  def self.has_field?(field_name)
    @@field_names.include?(field_name.to_sym)
  end

  field :id
  field :source, :target
  field :start,  :end
  field :label
  field :weight
  field :count
  field :attvalues
  # field :community
  field :community_id
  # field :edges
  field :words
end
