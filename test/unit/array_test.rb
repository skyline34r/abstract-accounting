require 'test_helper'
require "action_array"

class Test1
  attr_reader :test
  def initialize(test)
    @test = test
  end
end

class Test2
  attr_reader :test1
  def initialize(test1)
    @test1 = test1
  end
end

class ArrayTest < ActiveSupport::TestCase
  test "array compare value in where" do
    assert_equal 1, [1, 2, 3, 4].where(1).length, "Invalid length"
    assert_equal 2, ["hello", "2", "hello", "4"].where("hello").length, "Invalid length after filter array"
    assert_equal 0, ["hello", "2", "hello", "4"].where("hello1").length, "Invalid length after filter array"
  end

  test "compare object attribute full comparison" do
    t = Test1.new("hello2")
    a = [Test1.new("hello"),
         Test1.new("hello1"),
         t]
    assert_equal 3, a.length, "Wrong array length"
    assert_equal 1, a.where(:test => "hello").length, "Wrong length after where"
    assert_equal 1, a.where("test" => "hello1").length, "Wrong length after where"
    assert_equal t, a.where(:test => "hello2")[0], "Wrong object after where"
    assert_equal 3, a.length, "Wrong array length"
  end

  test "get all objects by attribute from second level" do
    a = [Test2.new(Test1.new("hello")),
         Test2.new(Test1.new("hello1")),
         Test2.new(Test1.new("hello2"))]
    assert_equal 3, a.length, "Wrong array length"
    assert_equal 1, a.where('test1.test' => "hello1").length, "Wrong length after where"
    assert_equal 3, a.length, "Wrong array length"
  end

  test "find objects by like" do
    a = [Test2.new(Test1.new("hello")),
         Test2.new(Test1.new("hello1")),
         Test2.new(Test1.new("hello2"))]
    assert_equal 3, a.length, "Wrong array length"
    assert_equal 3, a.where('test1.test' => {:like => "hello"}).length, "Wrong length after where"
    assert_equal 1, a.where('test1.test' => {:like => "1"}).length, "Wrong length after where"
    assert_equal 1, a.where('test1.test' => {:like => "hello2"}).length, "Wrong length after where"
    assert_equal 3, a.where('test1.test' => {:like => "ell"}).length, "Wrong length after where"
  end
end
