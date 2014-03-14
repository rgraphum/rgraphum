# -*- coding: utf-8 -*-

class VertexValueMatrix
  class << self
    def build(data,options={})
      options = { sample_size:10_000 }.merge(options)
      vertex_labels = pickup_vertex_labels(data)
      value_labels = picup_value_labels(data)
      
      # value_be_check
      data = add_count_values(data) if data[0].size == 2
      
      # make label and index hash
      value_label_index_hash = make_index_hash(value_labels)
      vertex_label_index_hash = make_index_hash(vertex_labels)
      
      puts "size vertex:      #{vertex_labels.size}"
      puts "size vector_size: #{value_labels.size}"
      
      vertex_value_matrix = Array.new(vertex_labels.size).map!{ |i| Array.new( value_labels.size, 0.0 ) }
      count_array = Array.new(vertex_labels.size).map!{ |i| Array.new( value_labels.size, 0   ) }
      
      # make item_user_matrix
      # examle:
      #           valueA valueB
      # vertexA [ [   1      2   ],
      # vertexB   [   0      1   ] ]
      
      data.each_with_index do  |( vertex_label,value_label,value ),row_i|
        j = vertex_label_index_hash[vertex_label]
        i = value_label_index_hash[value_label]

        next p row_i.to_s + ":no value data" unless value

        vertex_value_matrix[ vertex_label_index_hash[vertex_label] ] [ value_label_index_hash[value_label] ] ||=0
        vertex_value_matrix[ vertex_label_index_hash[vertex_label] ] [ value_label_index_hash[value_label] ] += value
      end
      
      
      # sampling
      if vertex_labels.size > options[:sample_size]
puts    "sampling" 
        vertex_value_matrix,vertex_labels = data_sampling(vertex_value_matrix,vertex_labels,options[:sample_size])
      end

      # del with customer zero
      t_vertex_value_matrix = vertex_value_matrix.transpose
      t_vertex_value_matrix.delete_if do |values|
        values.inject(:+) == 0
      end
      vertex_value_matrix = t_vertex_value_matrix.transpose
      
  p   "x sise"
  p   vertex_value_matrix.size   
  p   "y size"
  p   vertex_value_matrix[0].size
      [vertex_value_matrix,vertex_labels]
    end
    
    def pickup_vertex_labels(data)
p      labels = data.transpose[0].uniq
    end

    def picup_value_labels(data)
      labels = data.transpose[1].uniq
    end

    def make_index_hash(array)
      index_hash = {}
      array.each_with_index{|value,i| index_hash[value] = i }
      index_hash
    end

    def add_count_values(data)
      t_data = data.transpose
      count_values = Array.new(t_data[0].size,1.0)
      data = ( t_data << count_values ).transpose
    end
    
    def data_sampling(data,labels,size)
      sample_index = (0...data.size).to_a.sample(size)
      labels = sample_index.map { |index| labels[index] }
      data = sample_index.map { |index| data[index] }
      [data,labels]
    end

    def zero_filter(data,labels=[])
      t_data = data.transpose
      t_data.delete_if do |values|
        flg = true
        values.each do |value|
          break flg = false if value > 0.0
        end
        flg
      end
      data = t_data.transpose
      
      # del with item size
      i = 0
      data.delete_if do |values|
        flg = true
        values.each do |value|
          break flg = false if value > 0.0
        end
        if flg
          labels.delete_at(i)
        else
          i = i + 1
        end
        flg
      end
      [data,labels]
    end

    def sum_limit_filter(data,labels=[],limit_hash={})
      limit_hash = {vertex_limit:0,value_limit:0}.merge(limit_hash)

      t_data = data.transpose
      t_data.delete_if do |values|
        next false if values.inject(:+) > limit_hash[:value_limit]
        true
      end
      data = t_data.transpose

      i = 0
      data.delete_if do |values|
        if values.inject(:+) > limit_hash[:vertex_limit]
          i = i + 1
          next false
        end
       
        labels.delete_at(i)
        true
      end
      [data,labels]
      
    end

  end
end

