# -*- coding: utf-8 -*-

module Rgraphum::Marshal
  def self.included(base)
    base.__send__ :include, InstanceMethods
    base.__send__ :extend,  ClassMethods
  end

  module InstanceMethods
    def dump_to(path)
      data = Marshal.dump(self)
      File.write(path, data)
    end
  end

  module ClassMethods
    def load_from(path)
      data = File.read(path)
      graph = Marshal.load(data)
      unless graph.is_a?(self)
        raise TypeError, "No #{self} instance in: #{path} (#{graph.class})"
      end
      graph
    end
  end
end
