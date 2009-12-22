require 'test_helper'

class FinderOptionsTest < Test::Unit::TestCase
  include MongoMapper

  should "raise error if provided something other than a hash" do
    lambda { FinderOptions.new }.should raise_error(ArgumentError)
    lambda { FinderOptions.new(1) }.should raise_error(ArgumentError)
  end

  should "have symbolize the keys of the hash provided" do
    FinderOptions.new('offset' => 1).options.keys.map do |key|
      key.should be_instance_of(Symbol)
    end
  end

  context "#criteria" do
    should "convert conditions to criteria" do
      FinderOptions.expects(:to_mongo_criteria).with(:foo => 1).returns({})
      FinderOptions.new(:conditions => {:foo => 1}).criteria
    end
  end

  context "#options" do
    should "convert options to mongo options" do
      FinderOptions.expects(:to_mongo_options).with(:order => 'foo asc', :select => 'foo,bar').returns({})
      FinderOptions.new(:order => 'foo asc', :select => 'foo,bar').options
    end
  end

  context "Converting conditions to criteria" do
    should "work with simple criteria" do
      FinderOptions.to_mongo_criteria(:foo => 'bar').should == {
        :foo => 'bar'
      }

      FinderOptions.to_mongo_criteria(:foo => 'bar', :baz => 'wick').should == {
        :foo => 'bar',
        :baz => 'wick'
      }
    end

    should "use $in for arrays" do
      FinderOptions.to_mongo_criteria(:foo => [1,2,3]).should == {
        :foo => {'$in' => [1,2,3]}
      }
    end

    should "not use $in for arrays if already using array operator" do
      FinderOptions.to_mongo_criteria(:foo => {'$all' => [1,2,3]}).should == {
        :foo => {'$all' => [1,2,3]}
      }

      FinderOptions.to_mongo_criteria(:foo => {'$any' => [1,2,3]}).should == {
        :foo => {'$any' => [1,2,3]}
      }
    end

    should "work arbitrarily deep" do
      FinderOptions.to_mongo_criteria(:foo => {:bar => [1,2,3]}).should == {
        :foo => {:bar => {'$in' => [1,2,3]}}
      }

      FinderOptions.to_mongo_criteria(:foo => {:bar => {'$any' => [1,2,3]}}).should == {
        :foo => {:bar => {'$any' => [1,2,3]}}
      }
    end
  end

  context "skip" do
    should "default to 0" do
      FinderOptions.to_mongo_options({})[:skip].should == 0
    end

    should "use offset provided" do
      FinderOptions.to_mongo_options(:skip => 2)[:skip].should == 2
    end

    should "covert string to integer" do
      FinderOptions.to_mongo_options(:skip => '2')[:skip].should == 2
    end
  end

  context "limit" do
    should "default to 0" do
      FinderOptions.to_mongo_options({})[:limit].should == 0
    end

    should "use offset provided" do
      FinderOptions.to_mongo_options(:limit => 2)[:limit].should == 2
    end

    should "covert string to integer" do
      FinderOptions.to_mongo_options(:limit => '2')[:limit].should == 2
    end
  end

  context "fields" do
    should "default to nil" do
      FinderOptions.to_mongo_options({})[:fields].should be(nil)
    end

    should "be converted to nil if empty string" do
      FinderOptions.to_mongo_options(:fields => '')[:fields].should be(nil)
    end

    should "be converted to nil if []" do
      FinderOptions.to_mongo_options(:fields => [])[:fields].should be(nil)
    end

    should "should work with array" do
      FinderOptions.to_mongo_options({:fields => %w(a b)})[:fields].should == %w(a b)
    end

    should "convert comma separated list to array" do
      FinderOptions.to_mongo_options({:fields => 'a, b'})[:fields].should == %w(a b)
    end

    should "also work as select" do
      FinderOptions.new(:select => %w(a b)).options[:fields].should == %w(a b)
    end
  end
end # FinderOptionsTest
