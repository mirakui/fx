$: << File.join(File.dirname(__FILE__), '..', 'lib')
require 'loggable'
require 'date'
require 'sbi'

class SbiRecorder

  include Gena::Loggable

  BASE_DIR  = File.join(File.dirname(__FILE__), '..')
  LOG_DIR   = File.join(BASE_DIR, 'log')
  PRICE_DIR = File.join(LOG_DIR,  'price')
  RECORD_CURRENCIES = ["USD/JPY", "EUR/JPY", "GBP/JPY"]

  def initialize(sbi)
    @sbi = sbi
  end

  def record
    prices = @sbi.prices
    RECORD_CURRENCIES.each do |currency|
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
    File.join PRICE_DIR, record_file_name
  end

end

__END__

sbi = Sbi.new
rec = SbiRecorder.new(sbi)

rec.record

