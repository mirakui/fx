
class Market

  def reload_prices
    raise 'must be overriden'
  end

  def prices
    raise 'must be overriden'
  end

end

