# -*- coding: utf-8 -*-

#require 'numru/lapack'

class Rgraphum::Analyzer::LinearRegression
  def analyze(x_array, y_array, degree=1, round=5)

    nrow = x_array.size
    nx   = NArray.to_na(x_array)
    nxm  = NMatrix.sfloat(nrow,degree + 1)

    (degree + 1).times.each do |d|
      nxm[(degree - d) * nrow] = nx ** d
    end

    ny = NArray.to_na([y_array])
    s, rank, work, info, b = NumRu::Lapack.dgelsd(nxm, ny, 0)

    b.to_a[0].map { |n| n.round(round) }

  end
end
