class StockReport < String
  
  attr_reader :stock
  
  def initialize(stock)
    @stock = stock
    self << current_vitals <<            
            "\n" << ten_year_report <<
            "\n" << predictions <<
            "\n" << urls <<
            "\n\n"
  end
  
  def current_vitals
    "" << stock.symbol << " " <<
    dollar(stock.price) << " eps:" << dollar(stock.eps) << " PE:" << decimal(stock.pe_ratio)
  end
  
  def ten_year_report
    output = "Ten Year History\n" +
             "  Date         EPS        Book Sales  PE\n" + 
             "  --------------------------------------"  
    stock.ten_year_report.reports.each_with_index do |report, i|
      previous_report = stock.ten_year_report.reports[i+1]
      output << "\n  " << report.date.strftime("%m/%Y")
      output << " " << dollar(report.eps).rjust(8)
      output << " " << percent_change(previous_report, report, :eps).rjust(5)
      output << " " << percent_change(previous_report, report, :book_value_per_share).rjust(5)
      output << " " << percent_change(previous_report, report, :sales).rjust(5)
      output << " " << decimal(report.average_pe_ratio, 1).rjust(5)
    end
    output
  end
  
  def predictions
    output = "Predictions:"
    output << 
      "\n  growth:       " << percent(stock.predicted_growth_rate - 1.0) <<
      "\n  PE:           " << decimal(stock.predicted_pe_ratio, 1) <<
      "\n  10yr price:   " << dollar(stock.ten_year_price) <<
      "\n  sticker:      " << dollar(stock.sticker_price) <<
      "\n  deal ratio:   " << decimal(stock.deal_ratio, 1) <<
      "\n  payback time: " << decimal(stock.payback_time) << " years"
  end
  
  def urls
    "URLS:" + [
     "http://www.google.com/finance?q=#{stock.symbol}",
     "http://moneycentral.msn.com/investor/research/sreport.asp?symbol=AAPL&Y1=1&CR=1&AIE=1&AIR=1&FRH=1&FRK=1&ISA=1&ISQ=1&BSA=1&BSQ=1&CFA=1&CFQ=1&TYS=1&Type=Equity"
    ].map{|url| "\n  #{url}"}.join
  end
  
  NA = "."
     
  def dollar(price)
    return NA unless price
    "$%.2f" % price
  end
  
  def decimal(value, decimals=2)
    return NA unless value
    "%.#{decimals}f" % value
  end
  
  def percent(value, decimals=0)
    return NA unless value
    "%.#{decimals}f%" % (value * 100)
  end
  
  def percent_change(old, new, attribute=nil)
    if attribute && old && new
      old = old.send(attribute)
      new = new.send(attribute)
    end
    return NA unless old && new
    return NA if old == 0
    change = (new - old) / old
    percent(change)
  end  
  
end
