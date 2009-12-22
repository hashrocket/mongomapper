require File.dirname(__FILE__) + "/../test_helper"

class TimeZonesTest < Test::Unit::TestCase
  context "An instance of an embedded document" do
    setup do
      @document = Class.new do
        include MongoMapper::EmbeddedDocument
        key :name, String
        key :created_at, Time
      end
      @original_time = Time.parse("2009-08-15 14:00:00")
    end

    should "work without Time.zone" do
      # Because we have not yet defined a timezone.

      doc = @document.new(:created_at => @original_time)
      doc.created_at.should eql(@original_time)
    end

    should "work with Time.zone set to the (default) UTC" do
      begin
        require 'activesupport'
        Time.zone = "UTC"

        # Returned object should be a UTC TimeWithZone
        doc = @document.new(:created_at => @original_time)
        doc.created_at.is_a?(ActiveSupport::TimeWithZone).should == true
        doc.created_at.should eql(Time.zone.parse(@original_time.to_s))
      rescue LoadError
        puts "You need activesupport to run this test."
        pending
      end
    end


    should "work with timezones that are not UTC" do
      begin
        require 'activesupport'
        Time.zone = "Eastern Time (US & Canada)"

        # Returned object should be an American Eastern TimeWithZone
        doc = @document.new(:created_at => @original_time)
        doc.created_at.should eql(Time.zone.parse(@original_time.to_s))
      rescue LoadError
        puts "You need activesupport to run this text."
        pending
      end
    end
  end
end

