# -*- coding: utf-8 -*-

module Rgraphum::RgraphumArrayDividers
  def divide_by_time(interval=20)
    # interval is min

    base_sec = interval * 60

    each do |item|
      if item.start
        item.start = time_rounddown(item.start, base_sec)

        if item.end
          item.end = time_roundup(item.end,   base_sec)
        else
          item.end = time_roundup(item.start, base_sec)
        end

        if item.end > (item.start + base_sec)
          (item.start.to_i + base_sec).step(item.end.to_i, base_sec) do |t|
            new_item = item.dup
            new_item.id = nil
            new_item.start = Time.at(t)
            new_item.end   = Time.at(t + base_sec - 1)

            self << new_item
          end
          item.end = Time.at(item.start.to_i + base_sec - 1)
        end
      end
    end
  end

  private

  def time_rounddown(time, sec)
    Time.at((time.to_i / sec) * sec)
  end

  def time_roundup(time, sec)
    Time.at((time.to_i / sec) * sec + sec - 1)
  end
end
