require 'gena/loggable'

class Strategy

  include Gena::Loggable

  attr_accessor :trader, :params

  def initialize(trader,params={})
    @trader = trader
    @params = params
  end

  def calc(price)
    raise 'must be overriden'
  end

end
