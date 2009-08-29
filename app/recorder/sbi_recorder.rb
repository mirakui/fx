require 'config/environment'
require 'date'
require 'market_recorder'

class FileRecorder < MarketRecorder

  def initialize(sbi)
    @sbi = sbi
  end

  def record
    prices = @sbi.prices
    logger.debug "Record currency=[#{RECORD_CURRENCIES.join(',')}]"
    ::RECORD_CURRENCIES.each do |currency|
      write(currency, prices[currency])
    end
  end

  private
  def write(currency, price)
    open(record_file_path(currency), 'a') do |f|
      f.printf "%s\t%f\t%f\n", Time.now.to_s, price[:bid], price[:ask]
    end
  end

  def record_file_path(currency)
    record_file_name = "price.#{currency.sub('/','_')}.#{Date.today.to_s}"
    File.join ::PRICE_DIR, record_file_name
  end

end

