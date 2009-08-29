require 'gena/loggable'

class Strategy

  include Gena::Loggable

  def initialize(trader)
    @trader = trader
  end

  def calc(price)
    raise 'must be overriden'
  end

end
