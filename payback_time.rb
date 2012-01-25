module PaybackTime

  class Stock
  
    attr_accessor :price, 
                  :eps, 
                  :predicted_growth_rate, # 1.2 for 20% growth
                  :predicted_pe_ratio

    def initialize(attributes={})
      self.attributes = attributes
    end
    
    def attributes= attributes
      attributes.each { |key, value| send("#{key}=", value) }
    end
    
    MINIMUM_EXPECTED_GROWTH_RATE = 1.20
    
    def ten_year_eps 
      @ten_year_eps ||= eps * (predicted_growth_rate**10.0)
    end
    
    def ten_year_price
      @ten_year_price ||= ten_year_eps * predicted_pe_ratio
    end
        
    def sticker_price # predicted price in ten years - 20% growth
      @sticker_price ||= ten_year_price * (1/MINIMUM_EXPECTED_GROWTH_RATE)**10
    end
    
    def deal_ratio      
      @deal_ratio = sticker_price / price
    end
    
    def payback_time
      @payback_time ||= Math.log( price/eps, predicted_growth_rate )
    end
    
  end
end

  
    