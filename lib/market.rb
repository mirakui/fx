require 'gena/loggable'

class Market

  include Gena::Loggable

  def reload_prices
    raise 'must be overriden'
  end

  def prices
    raise 'must be overriden'
  end

end

