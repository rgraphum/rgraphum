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

    @rgraphum_id = new_rgraphum_id

    tmp[:weight] ||= 1
    fields.each do |key,value|
      tmp.store(key,value)
    end

    ElementManager.save(@rgraphum_id,tmp)
  end

#  def [](key)
#    ElementManager.fetch(@rgraphum_id,key)
#  end

  alias :original_store :store
  def store(key, value)
    ElementManager.store(@rgraphum_id,key,value)
    self.original_store(key, value)
  end
  alias :[]= :store

  # Non-Gremlin methods

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
