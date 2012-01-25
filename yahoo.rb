require 'open-uri'
require 'csv'

module Yahoo
  
  class Stock
  
    attr_reader :price, :eps
  
    def initialize symbol
      data = self.class.get symbol, %w{l1 e}
      @price    = data.shift.to_f  
      @eps      = data.shift.to_f
    end
    
    def self.get symbol, flags = []
      flags = flags.join if flags.respond_to?(:join)
      url = "http://finance.yahoo.com/d/quotes.csv?s=#{symbol}&f=#{flags}"
      csv = Cache.get(url, :expire => 60) { open(url).read.strip }
      csv.split(",")
    end
    
  end
  
end
