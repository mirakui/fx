require 'gena/loggable'

class MarketRecorder

  include Gena::Loggable

  def record
    raise 'must be overriden'
  end

end
