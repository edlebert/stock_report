module WeightedAverage

  def weighted_average
    weighted_sum = 0.0
    weighted_total = 0
    each_with_index do |number, i|
      next unless number
      weight = length - i
      weighted_sum += weight * number
      weighted_total += weight
    end
    weighted_sum / weighted_total
  end

end

Array.send :include, WeightedAverage

if $0 == __FILE__
  p [3,2,1].weighted_average
end