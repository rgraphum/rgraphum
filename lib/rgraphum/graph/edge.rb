# -*- coding: utf-8 -*-

def Rgraphum::Edge(hash_or_edge)
  if hash_or_edge.instance_of?(Rgraphum::Edge)
    hash_or_edge
  else
    Rgraphum::Edge.from_hash(hash_or_edge)
  end
end

class Rgraphum::Edge < Hash
  attr_accessor :graph
  attr_accessor :rgraphum_id

  class << self
    def from_hash(fields)
      tmp = new

      unless fields[:source] && fields[:target]
        raise ArgumentError, "Edge.new: :source and :target options are required"
      end

      tmp.rgraphum_id = new_rgraphum_id
      if fields[:source].is_a?(Hash)
        fields[:source] = fields[:source].id
      end
      @source = fields[:source]
    
      if fields[:target].is_a?(Hash)
        fields[:target] = fields[:target].id
      end
      @target = fields[:target]

      if fields[:start].class == Fixnum
        fields[:start] = Time.at(fields[:start])
      end

      fields[:weight] ||= 1

      fields.each do |key,value|
        tmp.store(key,value)
      end

      tmp
    end
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

  def reload
    hash = ElementManager.load(@rgraphum_id)
    hash.each do |key,value|
      self.original_store(key, value)
    end
    self
  end

  def dup
    tmp = super
    tmp.redis_dup
    tmp
  end

  def id
    self.[](:id).to_i if self.[](:id)
  end
  def id=(tmp)
    self.store(:id,tmp)
  end

  def source
    @graph.vertices.find_by_id( self.[](:source).to_i )
  end
  def source=(tmp)
    tmp = tmp.id if tmp.is_a?(Hash)
    @source = tmp
    self.store(:source,@source)
  end

  def target
    return nil unless @graph
    @graph.vertices.find_by_id(self.[](:target).to_i)
  end
  def target=(tmp)
    tmp = tmp.id if tmp.is_a?(Hash)
    @target = tmp
    self.store(:target,@target)
  end

  def label
    self.[](:label)
  end
  def label=(tmp)
    self.store(:label,tmp)
  end

  def weight
    self.[](:weight).to_f
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
