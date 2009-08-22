# vim:fileencoding=utf-8
$: << File.join(File.dirname(__FILE__), '..', 'lib')
require 'method_adder'

class Fruit < Gena::MethodAdder

  def initialize(value)
    @value = value
  end

  def value
    @value
  end
end

FruitSpecArgsSample = [
  :apple ,{
    :color => proc {
      "red"
    },
    :price => proc {
      value
    }
  }
]

describe "MethodAdderを継承したclass Fruitを定義する場合" do

  it "メソッドcolor(:apple),price(:apple)を追加できること" do
    Fruit.add(*FruitSpecArgsSample)
    Fruit.method_defined?("__color_apple").should be_true
    Fruit.method_defined?("__price_apple").should be_true
  end

  it "メソッドcolorが追加されていること" do
    Fruit.method_defined?("__color_apple").should be_true
  end

  it "メソッドpriceが追加されていること" do
    Fruit.method_defined?("__price_apple").should be_true
  end

end

describe "Fruitのインスタンスを作成したとき" do

  before do
    Fruit.add(*FruitSpecArgsSample)
    @fruit = Fruit.new(100)
  end

  it "メソッドcolor(:apple)が'red'を返すこと" do
    @fruit.should_not be_nil
    @fruit.color(:apple).should == 'red'
  end

  it "メソッドprice(:apple)がFruitのメンバ関数を参照できること" do
    @fruit.price(:apple).should == 100
  end

  # after do
  # end
end


