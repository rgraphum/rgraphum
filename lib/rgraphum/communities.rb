# -*- coding: utf-8 -*-

def Rgraphum::Communities(array)
  if array.instance_of?(Rgraphum::Communities)
    array
  else
    Rgraphum::Communities.new(array)
  end
end

class Rgraphum::Communities < Rgraphum::RgraphumArray

  # Non-Gremlin methods

  # FIXME
  # def dup
  # end

  # add community in communities
  # @param [Hash] community_hash one community, it is hash.
  # @return [Community] added community.
  def build(community_hash={})
    community = new_community(community_hash)
    original_push_1 community
    community
  end

  alias :original_push_1 :<<
  def <<(community_hash)
    build(community_hash)
    self
  end

  alias :original_push_m :push
  def push(*community_hashs)
    community_hashs.each do |community_hash|
      self << community_hash
    end
    self
  end

  # Called from delete_if, reject! and reject
  def delete(community_or_id)
    if community_or_id.is_a?(Rgraphum::Community)
      target_community = community_or_id
    else
      target_community = where(id: community_or_id).first
    end
    super(target_community)
  end

  protected :original_push_1
  protected :original_push_m

  private

  def new_community(community_hash={})
    if community_hash.is_a?(Hash)
      community_hash = community_hash.dup
      community_hash[:graph] = @graph
      community_hash[:id] ||= new_id
    end
    Rgraphum::Community(community_hash)
  end
end
