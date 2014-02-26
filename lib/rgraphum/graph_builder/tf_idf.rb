# encoding: utf-8

#require 'matrix'
#require 'inline'

class TfIdf
  def tf_idf(matrix)
    row_size = matrix.size.to_f

    idf = matrix.transpose.map do |col_array|
      df = col_array.select{|n| n > 0 }.size.to_f
      Math.log( row_size / df )
    end

    matrix.map do |row_array|
      row_sum = row_array.inject(&:+).to_f
      
      tmp = []
      row_array.each_with_index do |n,i|
        tmp << ( n / row_sum ) * idf[i]
      end
      tmp
    end
    
  end

end
