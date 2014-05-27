# -*- coding: utf-8 -*-

def Rgraphum::Edge(hash_or_edge)
  if hash_or_edge.instance_of?(Rgraphum::Edge)
    hash_or_edge
  else
    Rgraphum::Edge.new(hash_or_edge)
  end
end

class Rgraphum::Edge < Hash
  attr_accessor :graph
  # attr_accessor :vertex

  def initialize(fields={})
    tmp = super(nil)

    unless fields[:source] && fields[:target]
      raise ArgumentError, "Edge.new: :source and :target options are required"
    end

    fields.each do |key,value|
      tmp.store(key,value)
    end

    tmp[:weight] ||= 1

    tmp
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

#
#
#  field :attvalues

  def id
    self.[](:id)
  end
  def id=(tmp)
    self.store(:id,tmp)
  end

  def source
    self.[](:source)
  end
  def source=(tmp)
    self.store(:source,tmp)
  end

  def target
    self.[](:target)
  end
  def target=(tmp)
    self.store(:target,tmp)
  end

  def label
    self.[](:label)
  end
  def label=(tmp)
    self.store(:label,tmp)
  end

  def weight
    self.[](:weight)
  end
  def weight=(tmp)
    self.store(:weight,tmp)
  end

  def start
    self.[](:start)
  end
  def start=(tmp)
    self.store(:start,tmp)
  end

  def attvalues
    self.[](:attvalues)
  end
  def attvalues=(tmp)
    self.store(:attvalues,tmp)
  end

  def created_at
    self.[](:created_at)
  end
  def created_at=(tmp)
    self.store(:created_at,tmp)
  end

end
