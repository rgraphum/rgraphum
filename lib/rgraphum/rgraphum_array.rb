# -*- coding: utf-8 -*-

require_relative 'query'

class Rgraphum::RgraphumArray < Array
  attr_accessor :graph

#  def ids
#    map { |obj| obj.id }
#  end

  # FIXME use initialize_copy instead
  def dup
    array = self.class.new
    each do |item|
      array << item.dup
    end
    array
  end

  def self.reset_id
    remove_instance_variable :@new_id
  end

  # FIXME maybe better id to start from 1
  # def self.new_id
  #   @new_id ||= -1
  #   @new_id += 1
  # end

  def new_id(id=nil)
    # self.class.new_id
    @new_id ||= -1
    if id
      @new_id = id if @new_id < id
      id
    else
      @new_id += 1
    end
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

  alias :original_reject :reject
  def reject(&block)
    dup.reject! &block
  end

  def where(*conditions)
    Rgraphum::Query.new(self, *conditions)
  end

  # gremlin methods

  # has
  # Allows an element if it has a particular property. Utilizes several options for comparisons through T:
  #   T.gt - greater than
  #   T.gte - greater than or equal to
  #   T.eq - equal to
  #   T.neq - not equal to
  #   T.lte - less than or equal to
  #   T.lt - less than
  # It is worth noting that the syntax of has is similar to g.V("name", "marko"), which has the difference of being a key index lookup and as such will perform faster. In contrast, this line, g.V.has("name", "marko"), will iterate over all vertices checking the name property of each vertex for a match and will be significantly slower than the key index approach.
  #   gremlin> g.V.has("name", "marko").name
  #   ==>marko
  #   gremlin> g.v(1).outE.has("weight", T.gte, 0.5f).weight
  #   ==>0.5
  #   ==>1.0
  #   gremlin> g.V.has("age", null).name
  #   ==>lop
  #   ==>ripple
  def has(*conditions)
    if conditions.size == 1
      self.class.new( where( conditions[0], :!=, nil ) )
    elsif conditions.size == 2
      self.class.new( where( { conditions[0] => conditions[1] } ) )
    elsif conditions.size == 3
      self.class.new( where( *conditions ) )
    end
  end

  # hasNot
  # Allows an element if it does not have a particular property. Utilizes several options for comparisons on through T:
  #   T.gt - greater than
  #   T.gte - greater than or equal to
  #   T.eq - equal to
  #   T.neq - not equal to
  #   T.lte - less than or equal to
  #   T.lt - less than
  #   gremlin> g.v(1).outE.hasNot("weight", T.eq, 0.5f).weight
  #   ==>1.0
  #   ==>0.4
  #   gremlin> g.V.hasNot("age", null).name
  #   ==>vadas
  #   ==>marko
  #   ==>peter
  #   ==>josh
  def hasNot(*conditions)
    nor_hash = {
      :== => :!=,
      :!= => :==,
      :<  => :>=,
      :<= => :> ,
      :>= => :<,
      :>  => :<=,
    }

    if conditions.size == 1
      self.class.new( where( conditions[0], :==, nil ) )
    elsif conditions.size == 2
      where( conditions[0], :!=, conditions[1] )
    elsif conditions.size == 3
      where( conditions[0], nor_hash[conditions[1]], conditions[2] )
    end
  end

  def method_missing(name, *args)
    if first.class.has_field?(name)
      map{|item| item.send(name)}
    else
      super(name,*args)
    end
  end

end
