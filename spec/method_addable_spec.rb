# vim:fileencoding=utf-8
$: << File.join(File.dirname(__FILE__), '..')
require 'config/environment'
require 'gena/method_addable'

class Fruit < Gena::MethodAddable

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

describe Gena::MethodAddable, "を継承したclass Fruitを定義したとき" do

  it "メソッドcolor(:apple),price(:apple)を追加できること" do
    Fruit.add(*FruitSpecArgsSample)
    Fruit.method_defined?("__color_apple").should be_true
    Fruit.method_defined?("__price_apple").should be_true
  end

  it "メソッドcolorが追加されていること" do
    Fruit.method_defined?("color").should be_true
  end

  it "メソッドpriceが追加されていること" do
    Fruit.method_defined?("price").should be_true
  end

end

describe Gena::MethodAddable, "を継承したclass Fruitのインスタンスを作成したとき" do

  before do
    Fruit.add(*FruitSpecArgsSample)
    Fruit.add(:nil_fruit, :color => proc { nil })
    @fruit = Fruit.new(100)
  end

  it "メソッドcolor(:apple)が'red'を返すこと" do
    @fruit.should_not be_nil
    @fruit.color(:apple).should == 'red'
  end

  it "メソッドprice(:apple)がFruitのメンバ関数を参照できること" do
    @fruit.price(:apple).should == 100
  end

  it "メソッドcolor(:nil_fruit)が追加できること" do
    Fruit.method_defined?("__color_nil_fruit").should be_true
    @fruit.color(:nil_fruit).should be_nil
  end

  it "nounを複数指定したメソッドがちゃんと動くこと" do
    Fruit.method_defined?("__color_nil_fruit").should be_true
    Fruit.method_defined?("color").should be_true
    @fruit.color(:nil_fruit, :apple).should == "red"
  end

end


