# -*- coding: utf-8 -*-

def Rgraphum::Edge(hash_or_edge)
  if hash_or_edge.instance_of?(Rgraphum::Edge)
    hash_or_edge
  else
    Rgraphum::Edge.new(hash_or_edge)
  end
end

class Rgraphum::Edge # < Hash
  attr_accessor :graph
  # attr_accessor :vertex

  def initialize(fields={})
    unless fields[:source] && fields[:target]
      raise ArgumentError, "Edge.new: :source and :target options are required"
    end

    self.source = fields.delete(:source)
    self.target = fields.delete(:target)

    unknown_fields = fields.keys - @@field_names
    unless unknown_fields.empty?
      raise ArgumentError, "No such field(s) in Vertex: #{unknown_fields.join(', ')}"
    end
    fields.each do |name, value|
      self.send("#{name}=", value)
    end

    self.weight ||= 1
  end

  # Gremlin: outV
  #
  # Get both outgoing tail vertex of the edge.
  #
  #     gremlin> e = g.e(12)
  #     ==>e[12][6-created->3]
  #     gremlin> e.outV
  #     ==>v[6]
  #     gremlin> e.inV
  #     ==>v[3]
  #     gremlin> e.bothV
  #     ==>v[6]
  #     ==>v[3]
  #
  def outV
    self.source
  end
  alias :out_v :outV

  # Gremlin: inV
  #
  # Get both incoming head vertex of the edge.
  #
  #     gremlin> e = g.e(12)
  #     ==>e[12][6-created->3]
  #     gremlin> e.outV
  #     ==>v[6]
  #     gremlin> e.inV
  #     ==>v[3]
  #     gremlin> e.bothV
  #     ==>v[6]
  #     ==>v[3]
  #
  def inV
    self.target
  end
  alias :in_v :inV

  # Gremlin: bothV
  #
  # Get both incoming and outgoing vertices of the edge.
  #
  #     gremlin> e = g.e(12)
  #     ==>e[12][6-created->3]
  #     gremlin> e.outV
  #     ==>v[6]
  #     gremlin> e.inV
  #     ==>v[3]
  #     gremlin> e.bothV
  #     ==>v[6]
  #     ==>v[3]
  #
  def bothV
    [outV, inV]
  end
  alias :both_v :bothV


  # Non-Gremlin methods


  # def id
  #   self[:id]
  # end

  def update_vertices(vertices)
    self.source = find_vertex(:source, vertices)
    self.target = find_vertex(:target, vertices)
  end
  
  def find_vertex(syn, vertices)
    vertex =  self[syn]
    if vertex.instance_of?(Rgraphum::Vertex) and vertex.graph.equal?(@graph)
      vertex
    else
      vertex = vertices.find_by_id(vertex)
    end

    unless vertex
      p "edge has no #{syn}" if Rgraphum.verbose?
    end
    vertex
  end

  # accessors

  # attr_accessor :id
  # attr_accessor :source, :target
  # attr_accessor :start,  :end
  # attr_accessor :label
  # attr_accessor :weight
  # attr_accessor :attvalues

  def [](key)
    send(key)
  end

  def []=(key, value)
    send("#{key}=")
  end

  def ==(other)
    if other.is_a?(Rgraphum::Edge)
      return false unless id == other.id
    else
      return id == other
    end
    return false unless source == other.source
    return false unless target == other.target
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
  field :attvalues
end
