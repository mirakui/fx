# vim:fileencoding=utf-8
$: << File.join(File.dirname(__FILE__), '..', 'lib')
require 'method_adder'

class MethodAdderSub

  def initialize(value)
    @value = value
  end

  def value
    @value
  end
end

describe "MethodAdderをincludeしたclass MethodAdderSubを定義する場合" do
  before do
    MethodAdderSub.include Gena::MethodAdder
  end

  it "メソッドsay(:hello),say(:value)を追加できること" do
    MethodAdderSub.send(:add_say ,{
      :hello => proc {
        "hello!"
      },
      :value => proc {
        value
      }
    })
    MethodAdderSub.protected_method_defined?("__say_hello").should be_true
    MethodAdderSub.protected_method_defined?("__say_value").should be_true
  end

  it "MethodAdderSubのインスタンスが作成できること" do
    @sub = MethodAdderSub.new(100)
    @sub.should_not be_nil
  end

  it "メソッドsay(:hello)が'hello'を返すこと" do
    @sub.say(:hello).should == 'hello'
  end

  it "メソッドsay(:value)がMethodAdderSubのメンバ関数を参照できること" do
    @sub.say(:value).should == 100
  end

  after do
  end
end


