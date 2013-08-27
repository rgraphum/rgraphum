# -*- coding: utf-8 -*-

# LinearRegression
# resolve with least squares method.
# ex. x = [1,2,3], y = [5,7,9]
#     y = ax + b 
#     a = 2, b = 3
# @param [Array] x_array x paramaters
# @param [Array] y_array y paramaters
# @return [Array] a,b
class Rgraphum::Analyzer::LinearRegression
  def analyze(x_array, y_array, degree=1, round=5)

     n      = x_array.size
     x_sum  = 0.0 
     y_sum  = 0.0 
     xy_sum = 0.0
     x2_sum = 0.0
     [x_array,y_array].transpose.each do |x,y|
       x_sum  += x
       y_sum  += y
       x2_sum += x**2
       xy_sum += x*y
     end

     a = ( n * xy_sum - x_sum * y_sum) / ( n * x2_sum - x_sum**2 )
     b = ( x2_sum * y_sum - xy_sum * x_sum ) / ( n * x2_sum - x_sum**2)

     [a.round(round),b.round(round)]
  end
end
