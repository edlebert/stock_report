require 'open-uri'
require './cache'
require 'date'

module MSNMoney

  class Stock
    
    attr_reader :symbol
    
    def initialize symbol
      @symbol = symbol.upcase
    end
    
    def ten_year_report
      @ten_year_report ||= TenYearReport.new(symbol)
    end
    
  end
  
  class TenYearReport
  
    attr_reader :symbol, :reports
  
    def initialize(symbol)
      @symbol  = symbol.upcase
      @reports = []
      build_ten_year_reports
      build_key_ratio_reports
    end
    
    def ten_year_summary_html
      url = "http://moneycentral.msn.com/investor/invsub/results/pstatemnt.aspx?symbol=#{symbol}&lstStatement=10YearSummary&stmtView=Ann"
      Cache.get(url, :expire => 60) { open(url).read }
    end    
    
    def build_ten_year_reports
      cells = ten_year_summary_html.scan(/<td.*?>(.*?)<\/td>/).map(&:first)
      raise "#{symbol} ten year summary doesn't contain a multiple of 12" unless cells.size % 12 == 0
      years = cells.size / 12 - 1 # subtract table headings
      raise "#{symbol} ten year summary is empty" if years <= 0
      cells.each { |c| c.gsub!(/[,]/, '') } # strip out commas
      table_a = cells.slice!(7, 7 * years)
      table_b = cells.slice!(7 + 5, 5 * years)
      while (table_a.any? || table_b.any?)
        row_a = table_a.slice!(0, 7)
        row_b = table_b.slice!(0, 5)
        date_a = row_a.shift
        date_b = row_b.shift
        raise "#{symbol} ten year summary row dates don't match: #{date_a} != #{date_b}" unless date_a == date_b
        date = Date.new(date_a.split('/').last.to_i + 2000, date_a.split('/').first.to_i)
        report = @reports.find{|r| r.date == date} || (@reports << Report.new(:date => date)).last
        report.sales              = row_a.shift.to_f
        report.ebit               = row_a.shift.to_f
        report.depreciation       = row_a.shift.to_f
        report.total_net_income   = row_a.shift.to_f
        report.eps                = row_a.shift.to_f
        report.tax_rate           = row_a.shift.to_f
        report.assets             = row_b.shift.to_f
        report.liabilities        = row_b.shift.to_f
        report.long_term_debt     = row_b.shift.to_f
        report.shares_outstanding = row_b.shift
      end
    end
    
    def key_ratios_html
      url = "http://moneycentral.msn.com/investor/research/sreport.asp?symbol=#{symbol}&FRK=1&Type=Equity"
      Cache.get(url, :expire => 60) { open(url).read }
    end  
    
    def build_key_ratio_reports
      # grab the last two tables
      tables = key_ratios_html.scan(/<table(.*?)<\/table>/).map(&:first).last(2)
      # scan the cells from the last two tables
      table_a, table_b = tables.map do |table|
        table.scan(/>([\-\$\d,.NA\/]+)<\//).map(&:first).map { |c| convert_key_ratio_cell(c) }
      end
      raise "#{symbol} key ratios table A doesn't contain a multiple of 5" unless table_a.size % 5 == 0
      raise "#{symbol} key ratios table B doesn't contain a multiple of 6" unless table_b.size % 6 == 0
      while (table_a.any? || table_b.any?)
        row_a = table_a.slice!(0, 5)
        row_b = table_b.slice!(0, 6)
        date_a = row_a.shift
        date_b = row_b.shift
        raise "#{symbol} key ratio row dates don't match: #{date_a} != #{date_b}" unless date_a == date_b
        date = date_a
        report = @reports.find{|r| r.date == date} || (@reports << Report.new(:date => date)).last
        report.average_pe_ratio     = row_a.shift
        report.price_per_sales      = row_a.shift
        report.price_per_book       = row_a.shift
        report.net_profit_margin    = row_a.shift
        report.book_value_per_share = row_b.shift
        report.debt_per_equity      = row_b.shift
        report.return_on_equity     = row_b.shift
        report.return_on_assets     = row_b.shift
        report.interest_coverage    = row_b.shift
      end
    end
    
    def convert_key_ratio_cell cell
      cell.gsub!(/[\$,]/, "")
      if cell.include?("/") # date
        month, year = cell.split("/").map(&:to_i)
        Date.new(year + 2000, month)
      elsif cell !~ /\d/ # NA
        nil
      elsif cell.include?(".")
        cell.to_f
      else
        cell.to_i
      end
    end
    
  end
  
  class Report
    attr_accessor :date,
                  # Ten Year Summary
                  :sales, :ebit, :depreciation, :total_net_income, :eps, :tax_rate,
                  :assets, :liabilities, :long_term_debt, :shares_outstanding,
                  # Key Ratios
                  :average_pe_ratio, :price_per_sales, :price_per_book, :net_profit_margin,
                  :book_value_per_share, :debt_per_equity, :return_on_equity, :return_on_assets,
                  :interest_coverage
    
    def initialize attributes={}
      self.attributes = attributes
    end
    
    def attributes= attributes
      attributes.each { |key, value| send("#{key}=", value) }
    end
  end
  
  
end  
