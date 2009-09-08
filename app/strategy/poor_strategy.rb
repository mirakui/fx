require 'strategy'
require 'gena/ring_buffer'

class PoorStrategy < Strategy

  def initialize(trader, params={})
    super trader
    @position_type = nil
    @position = nil
    @base_price = nil
    params[:currency]     ||= "USD/JPY"
    params[:trade_unit]   ||= 1
    params[:sonkiri_line] ||= 1.0
    params[:rigui_line]   ||= 0.05
    params[:price_buffer_size] ||= 10
    @price_buffer = RingBuffer.new(params[:price_buffer_size])
    self.params = params
  end

  def calc(price)
    debug_out "Calc: base_price=#{@base_price.inspect}, current_price=#{price.inspect}"
    @price_buffer << price[:bid]
    if @base_price.nil?
      debug_out "base_price is nil, now initializing"
      order_next_position(price)
      @base_price = price
      return
    end
    should_close_position = false
    case @position_type
    when :buy
      should_close_position = (price[:bid] >= @base_price[:ask] + params[:rigui_line]) || (price[:bid] <= @base_price[:ask] - params[:sonkiri_line])
    when :sell
      should_close_position = (price[:ask] <= @base_price[:bid] - params[:rigui_line]) || (price[:bid] >= @base_price[:ask] + params[:sonkiri_line])
    end
    if should_close_position
      debug_out "Trying to close the position: #{@position_type}"
      close_position(price)
      order_next_position(price)
      @base_price = price
    end
  end

  def close_position(price)
    trader.clear(params[:currency], @position_type, params[:trade_unit], @position_type==:buy ? price[:bid] : price[:ask])
    debug_out "Position Closed: cur=#{params[:currency]}, type=#{@position_type.to_s}, unit=#{params[:trade_unit]}, price=#{@position_type==:buy ? price[:bid] : price[:ask]}"
  end

  def order_next_position(price)
    position_type = decide_next_position_type
    trader.order(params[:currency], position_type, params[:trade_unit], position_type==:buy ? price[:ask] : price[:bid])
    @position_type = position_type
    debug_out "Next Position: cur=#{params[:currency]}, type=#{position_type.to_s}, unit=#{params[:trade_unit]}, price=#{position_type==:buy ? price[:ask] : price[:bid]}"
  end

  def decide_next_position_type
    #rand(2)==0 ? :buy : :sell
    diff = @price_buffer.differential
    debug_out "Differencial: #{diff}"
    diff > 0.0 ? :buy : :sell
    #diff < 0.0 ? :buy : :sell
    #:buy
    #rand(2)==0 ? :buy : :sell
  end

  def debug_out(msg)
    logger.debug msg if $DEBUG
  end

end
