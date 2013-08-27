# -*- coding: utf-8 -*-

class Rgraphum::Query
  include Enumerable

  def initialize(array, *conditions)
    @array = array
    @conditions = []
    @id_conditions = nil
    where(*conditions)
  end

  def each(&block)
    if block_given?
      all.each do |item|
        yield item
      end
    else
      to_enum
    end
  end

  def empty?
    all.empty?
  end

  # where(id: 3).first
  # where(label: "abc").all
  # where(id: 1, label: "abc").all
  # where(:label, :eq, "abc").all
  # where(:label, :ne, "abc").all
  def where(*conditions)
    if conditions.size == 1 && conditions[0].is_a?(Hash)
      conditions = conditions[0]
    end
    return self if conditions.empty?

    case conditions
    when Hash
      conditions.each do |fieldname, rvalue|
        condition = [fieldname, :eq, rvalue]
        @conditions << condition
        if fieldname == :id
          @id_conditions ||= []
          @id_conditions << condition
        end
      end
    when Array
      fieldname, operator, rvalue = conditions
      condition = [fieldname, operator, rvalue]
      @conditions << condition
      if fieldname == :id && (operator == :eq || operator == :==)
        @id_conditions ||= []
        @id_conditions << condition
      end
    else
      raise NotImplementedError
    end

    self
  end

  def all
    if @id_conditions && @array.respond_to?(:find_by_id)
      item = @array.find_by_id(@id_conditions.first[2])
      if try_conditions(item)
        [item]
      else
        []
      end
    else
      @array.class.new( @array.select { |item| try_conditions(item) } )
    end
  end
  alias :to_a :all

  def first
    if @id_conditions && @array.respond_to?(:find_by_id)
      item = @array.find_by_id(@id_conditions.first[2])
      return item if item && try_conditions(item)
    else
      @array.each do |item|
        return item if try_conditions(item)
      end
    end
    nil
  end

  def last
    if @id_conditions && @array.respond_to?(:find_by_id)
      item = @array.find_by_id(@id_conditions.first[2])
      return item if item && try_conditions(item)
    else
      @array.reverse_each do |item|
        return item if try_conditions(item)
      end
    end
    nil
  end

  def method_missing(method_name, *args)
    if @array.first.respond_to?(method_name)
      all.map { |item| item.send(method_name) }
    else
      super
    end
  end

  private

  def try_conditions(item)
    @conditions.each do |(fieldname, operator, rvalue)|
      lvalue = item.send(fieldname)
      case operator
      when :eq,  :==; return false unless lvalue == rvalue
      when :ne,  :!=; return false unless lvalue != rvalue
      when :gt,  :>;  return false unless lvalue >  rvalue
      when :gte, :>=; return false unless lvalue >= rvalue
      when :lt,  :<;  return false unless lvalue <  rvalue
      when :lte, :<=; return false unless lvalue <= rvalue
      when :match,     :=~; return false unless lvalue =~ rvalue
      when :not_match, :!~; return false unless lvalue !~ rvalue
      else
        raise ArgumentError, "Unknown operator #{operator}"
      end
    end
    true
  end

end
