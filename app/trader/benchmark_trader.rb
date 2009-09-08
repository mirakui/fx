require 'trader'

class BenchmarkTrader < Trader

  def initialize
    @histories = []
    @positions = {}
  end

  def order(currency, position_type, trade_unit, limit)
    @positions[currency] ||= {}
    pos = {
      :action_type   => :order,
      :currency      => currency,
      :position_type => position_type,
      :trade_unit    => trade_unit,
      :limit         => limit
    }
    @positions[currency][position_type] = pos
    @histories << pos
  end

  def clear(currency, position_type, trade_unit, limit)
    pos = @positions[currency][position_type] rescue nil
    raise "There is no position of #{currency}, #{position_type}" unless pos

    profit = calc_profit(pos, {:trade_unit => trade_unit, :limit => limit})
    his = {
      :action_type   => :clear,
      :currency      => currency,
      :position_type => position_type,
      :trade_unit    => trade_unit,
      :limit         => limit,
      :profit        => profit
    }
    @positions[currency][position_type] = nil
    @histories << his
  end

  def print_statistics
    took_profit_count  = 0
    stop_loss_count    = 0
    total_profit       = 0
    buy_count          = 0
    sell_count         = 0
    @histories.each do |his|
      next unless his[:action_type] == :clear
      if his[:profit] >= 0.0
        took_profit_count += 1
      else
        stop_loss_count += 1
      end
      total_profit += his[:profit]
      if his[:position_type] == :buy
        buy_count  += 1
      else
        sell_count += 1
      end
    end
    printf "%30s: %s\n", 'Profit/Loss Count',      "#{took_profit_count}/#{stop_loss_count}"
    printf "%30s: %s\n", 'Profit/Loss Count Rate', "#{took_profit_count.to_f/stop_loss_count}"
    printf "%30s: %s\n", 'Buy/Sell Count',         "#{buy_count}/#{sell_count}"
    printf "%30s: %s\n", 'Buy/Sell Count Rate',    "#{buy_count.to_f/sell_count}"
    printf "%30s: %s\n", 'Total Profit',           "#{total_profit}"
  end

  private
  def calc_profit(order, clear)
    case order[:position_type]
    when :buy
      clear[:limit] * clear[:trade_unit] - order[:limit] * order[:trade_unit]
    when :sell
      -(clear[:limit] * clear[:trade_unit] - order[:limit] * order[:trade_unit])
    else
      raise "Unexpected Position Type: #{order[:position_type].inspect}"
    end
  end

end
