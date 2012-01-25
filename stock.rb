require './yahoo.rb'
require './msn.rb'
require './payback_time.rb'
require './growth_rates.rb'
require './weighted_average.rb'

class Stock

  attr_reader :symbol
  attr_accessor :predicted_growth_rate, :predicted_pe_ratio

  def initialize(symbol, attributes={})
    @symbol = symbol.to_s.upcase
    self.attributes = attributes
    @yahoo = Yahoo::Stock.new(@symbol)
    @msn   = MSNMoney::Stock.new(@symbol)
    @payback_time = PaybackTime::Stock.new(
      :price => price,
      :eps   => eps,
      :predicted_growth_rate => predicted_growth_rate,
      :predicted_pe_ratio    => predicted_pe_ratio
    )
  end
  
  # Hash Setter for attributes
    
  def attributes= attributes
    attributes.each { |key, value| send("#{key}=", value) }
  end
  
  # Delegate to different stock APIs.
  
  [:price, :eps].each do |attribute|
    define_method(attribute) { @yahoo.send(attribute) }
  end
  
  [:ten_year_report].each do |attribute|
    define_method(attribute) { @msn.send(attribute) }
  end
  
  [:ten_year_price, :ten_year_eps, :sticker_price, :deal_ratio, :payback_time].each do |attribute|
    define_method(attribute) { @payback_time.send(attribute) }
  end
  
  def pe_ratio
    price / eps
  end
  
  # Predict EPS and PE Ratio's if not provided.
  
  def predicted_growth_rate
    @predicted_growth_rate ||= begin
      ten_year_report.reports.map(&:book_value_per_share).growth_rates.weighted_average
    end
  end
  
  def predicted_pe_ratio
    @predicted_pe_ratio ||= begin
      ([pe_ratio] + ten_year_report.reports.map(&:average_pe_ratio)).weighted_average
    end
  end

end
