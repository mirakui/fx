require 'gena/loggable'

class Trader

  include Gena::Loggable

  def order(currency, position_type, trade_unit)
    raise 'must be overriden'
  end

  def clear(currency, position_type, trade_unit)
    raise 'must be overriden'
  end

end

