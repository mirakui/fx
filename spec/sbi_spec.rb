# vim:fileencoding=utf-8
$: << File.join(File.dirname(__FILE__), '..', 'lib')
require 'sbi'

describe Sbi, "においてpboardページで相場情報を取得したとき" do

  before do
    @sbi = Sbi.new
    @prices = @sbi.reload_prices
  end

  it "取得した相場情報は計8通貨であること" do
    @prices.should have(8).items
  end

  it "取得した相場情報はUSD/JPYを含むこと" do
    @prices.should have_key('USD/JPY')
  end

  it "取得した相場情報はEUR/JPYを含むこと" do
    @prices.should have_key('EUR/JPY')
  end

  it "取得した相場情報はGBP/JPYを含むこと" do
    @prices.should have_key('GBP/JPY')
  end

  it "取得したすべての相場情報のBidは0より大きい数字であること" do
    @prices.each_value do |value|
      value[:bid].should be_a_kind_of Float
      value[:bid].should > 0
    end
  end

  it "取得したすべての相場情報のAskは0より大きい数字であること" do
    @prices.each_value do |value|
      value[:ask].should be_a_kind_of Float
      value[:ask].should > 0
    end
  end

  it "取得したすべての相場情報はBidよりAskの方が高いこと" do
    @prices.each_value do |value|
      value[:bid].should < value[:ask]
    end
  end

  it "3秒後にpricesを呼んだときにバッファが利用されていること" do
    sleep 3
    prices_reload = @sbi.reload_prices
    @prices.should == prices_reload
  end

  it "3秒後に再取得したとき相場に変化があること" do
    sleep 3
    prices_reload = @sbi.reload_prices
    @prices.keys.should == prices_reload.keys
    @prices.each_pair do |k,v|
      prices_reload[k][:bid].should_not == v[:bid]
      prices_reload[k][:ask].should_not == v[:ask]
    end
  end

end

