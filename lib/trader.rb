require 'loggable'

class Trader

  include Gena::Loggable

  def buy
    raise 'must be overriden'
  end

  def sell
    raise 'must be overriden'
  end

end

