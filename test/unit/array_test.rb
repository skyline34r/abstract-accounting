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

class Test3
  attr_reader :test1, :amount
  def initialize(test1, amount)
    @test1 = test1
    @amount = amount
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

  test "search by two fields" do
    a = [Test3.new(Test1.new("hello"), 34),
         Test3.new(Test1.new("hello1"), 35),
         Test3.new(Test1.new("hello2"), 3)]
    assert_equal 3, a.length, "Wrong array length"
    assert_equal 3, a.where('test1.test' => {:like => "hello"}, 'amount' => {:like => 3}).length, "Wrong length after where"
    assert_equal 1, a.where('test1.test' => {:like => "1"}, 'amount' => {:like => 3}).length, "Wrong length after where"
    assert_equal 1, a.where('test1.test' => {:like => "hello2"}, 'amount' => {:like => 3}).length, "Wrong length after where"
    assert_equal 3, a.where('test1.test' => {:like => "ell"}, 'amount' => {:like => 3}).length, "Wrong length after where"
  end

  test "order asc" do
    a = [1, 3, 5, 4, 2].order 'asc'
    idx = 1
    a.each do |item|
      assert item == idx, "Wrong item"
      idx += 1
    end
  end

  test "order desc" do
    a = [1, 3, 5, 4, 2].order 'desc'
    idx = 5
    a.each do |item|
      assert item == idx, "Wrong item"
      idx -= 1
    end
  end

  test "order by attribute - asc" do
    t1 = Test2.new(Test1.new("hello2"))
    t2 = Test2.new(Test1.new("hello"))
    t3 = Test2.new(Test1.new("hello1"))
    a = [t1, t2, t3].order 'test1.test' => 'asc'
    assert_equal t2, a[0], "Wrong 0 element"
    assert_equal t3, a[1], "Wrong 1 element"
    assert_equal t1, a[2], "Wrong 2 element"
  end

  test "order by attribute - desc" do
    t1 = Test2.new(Test1.new("hello"))
    t2 = Test2.new(Test1.new("hello1"))
    t3 = Test2.new(Test1.new("hello2"))
    a = [t1, t2, t3]
    a = a.order 'test1.test' => 'desc'
    assert_equal t3, a[0], "Wrong 0 element"
    assert_equal t2, a[1], "Wrong 1 element"
    assert_equal t1, a[2], "Wrong 2 element"
  end

  test "check desc order with bad object" do
    t1 = Test2.new(Test1.new("hello"))
    t2 = Test3.new(Test1.new("hello2"), 31)
    t3 = Test3.new(Test1.new("hello1"), 3)
    a = [t1, t2, t3]
    a = a.order 'amount' => 'desc'
    assert_equal t2, a[0], "Wrong 0 element"
    assert_equal t3, a[1], "Wrong 1 element"
    assert_equal t1, a[2], "Wrong 2 element"
  end

  test "check asc order with bad object" do
    t1 = 5
    t2 = Test3.new(Test1.new("hello2"), 31)
    t3 = Test3.new(Test1.new("hello1"), 3)
    a = [t1, t2, t3]
    a = a.order 'amount' => 'asc'
    assert_equal t1, a[0], "Wrong 0 element"
    assert_equal t3, a[1], "Wrong 1 element"
    assert_equal t2, a[2], "Wrong 2 element"
  end

  test "search by two fields with bad objects" do
    a = [5,
         Test3.new(Test1.new("hello1"), 35),
         Test3.new(Test1.new("hello2"), 3)]
    assert_equal 3, a.length, "Wrong array length"
    assert_equal 2, a.where('amount' => {:like => 3}).length, "Wrong length after where"
    assert_equal 1, a.where('amount' => {:like => 35}).length, "Wrong length after where"
  end
end
