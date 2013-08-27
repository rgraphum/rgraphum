# -*- coding: utf-8 -*-

# CosineSimilarity
# calc vector distance with cosine similarity
# ex. it make equilateral triangle
# [ [1,1,0],[1,0,1],[1,0,1] ]
# it's angle is 60. cosine 60 = 0.5,
# thus outputs is 
# [[1.0, 0.5, 0.5], [0.5, 1.0, 0.5], [0.5, 0.5, 1.0]]
#
class CosineSimilarityMatrix
  def similarity(matrix)
    sim_matrix = []

    # calc cosine similarity
    # @params [Array] matrix array of array
    # @return [Array] array of array cosine similarity matrix
    matrix.each_with_index do |row_fix,j|
      sim_array = []
      a2_sum = row_fix.inject(0.0){|sum,a| sum + a**2}
      matrix.each_with_index do |row_move,i|
        next sim_array << sim_matrix[i][j] if j > i
        next sim_array << 1.0 if i == j

        b2_sum = 0.0
        ab_sum = 0.0

        [row_fix,row_move].transpose.each do |a,b|
          b2_sum += b**2
          ab_sum += a*b 
        end
        sim_array << ab_sum / ( Math.sqrt(a2_sum * b2_sum) )
      end
      sim_matrix << sim_array
    end
    sim_matrix
  end

end

