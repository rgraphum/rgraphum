# -*- coding: utf-8 -*-

require_relative 'query'

class Rgraphum::Elements < Array

  attr_accessor :graph
  attr_reader   :rgraphum_id

  include ElementsManager

  def new_id(id=nil,element_rgraphum_id=nil)
    elements_manager.new_id(id,element_rgraphum_id)
  end

  def current_id
    elements_manager.current_id
  end

  def ids
    elements_manager.keys.freeze
  end

  def ids=(source=[])
    elements_manager.replace(source).freeze
  end  

  def add_ids(id)
    elements_manager.add_ids(id)
  end

  def del_ids
    ids_manager.del_ids(id)
  end

  def id_element_hash
    hash = {}
    id_rgraphum_hash.each do |id,rgraphum_id|
      hash[id.to_i] = ElemetManager.load(rgraphum_id)
    end
    hash
  end

  def id_rgraphum_id_hash
    elements_manager.load
  end

  def elements_manager
    @elements_manager ||= ElementsManager.new
  end

  def substitute(array, &block)
    return unless array.is_a?(Array)
    new_array = self.class.new
    new_array.graph = @graph
    array.each do |item|
      if block_given?
        new_array << (yield item)
      else
        new_array << item
      end
    end
    new_array
  end

  alias :original_delete_if :delete_if
  alias :original_reject!   :reject!
  def delete_if
    if block_given?
      i = 0
      size = self.size
      while i < size
        item = self[i]
        if yield(item)
          delete(item)
          size -= 1
        else
          i += 1
        end
      end
      self
    else
      to_enum
    end
  end
  alias :reject! :delete_if

  def where(*conditions)
    Rgraphum::Query.new(self, *conditions)
  end

  def method_missing(name, *args)
#    if first.class.has_feilds?(name)
      map{|item| item.send(name)}
#    else
#      super(name,*args)
#    end
  end

end
