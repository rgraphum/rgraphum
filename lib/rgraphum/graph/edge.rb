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

  def initialize(fields={})
    tmp = super(nil)

    unless fields[:source] && fields[:target]
      raise ArgumentError, "Edge.new: :source and :target options are required"
    end

    @rgraphum_id = new_rgraphum_id
    @source = fields[:source]
    @target = fields[:target]

    if fields[:start].class == Fixnum
      fields[:start] = Time.at(fields[:start])
    end

    fields[:weight] ||= 1
    fields.each do |key,value|
      tmp.store(key,value)
    end

    ElementManager.save(@rgraphum_id,tmp)
  end

  def redis_dup
    @rgraphum_id = ElementManager.redis_dup(@rgraphum_id)
  end

  def [](key)
    ElementManager.fetch(@rgraphum_id,key)
  end

  alias :original_store :store
  def store(key, value)
    ElementManager.store(@rgraphum_id,key,value)
    self.original_store(key, value)
  end
  alias :[]= :store
  
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

  def id
    self.[](:id)
  end
  def id=(tmp)
    self.store(:id,tmp)
  end

  def source
    @source
  end
  def source=(tmp)
    @source=tmp
    self.store(:source,tmp)
  end

  def target
    @target
  end
  def target=(tmp)
    @target=tmp
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

  def attvalues
    self.[](:attvalues)
  end
  def attvalues=(tmp)
    self.store(:attvalues,tmp)
  end

  def created_at
    return Time.now unless self.[](:created_at)
    Time.parse(time_string = self.[](:created_at))
  end
  def created_at=(tmp)
    self.store(:created_at,tmp)
  end

  def start
    return Time.now unless self.[](:start)
    Time.parse(time_string = self.[](:start))
  end
  def start=(tmp)
    self.[]=(:start,tmp)
  end

end
