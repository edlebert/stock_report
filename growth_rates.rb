module GrowthRates

  def growth_rates
    # Assume most recent is at index 0.
    rates = []
    each_with_index do |number, i|
      previous_number = self.at(i + 1)
      if previous_number && previous_number != 0
        rates << number.to_f / previous_number
      end
    end
    rates
  end
  
end

Array.send :include, GrowthRates

if $0 == __FILE__
  p [3,2,1,0].growth_rates
end