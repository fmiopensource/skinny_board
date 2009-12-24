#require File.dirname(__FILE__) + '/../spec_helper'

# NOTE - These were commented out for my sanity because these four tests often take 30+ seconds to run.
# Please uncomment them if you do any work with S3, even if you don't touch this class. - Grande
#describe S3Interface do
#  describe "saving a file" do
#    it "should require a file" do
#      lambda {S3Interface.save_to_s3('')}.should raise_error(ArgumentError)
#    end
#    it "should be able to find the file" do
#      lambda {S3Interface.save_to_s3('file.jpg')}.should raise_error()
#    end
#
#    it "should be able to save a file" do
#      lambda {S3Interface.save_to_s3('public/images/FMi.jpg')}.should_not raise_error
#    end
#
#    it "should accept an optional file name for S3" do
#      lambda {S3Interface.save_to_s3('public/images/FMi.jpg', 'FMi.jpg')}.should_not raise_error
#    end
#  end
#
#  describe "finding a file" do
#    it "should require a file name" do
#      lambda {S3Interface.retrieve_from_s3('')}.should raise_error(ArgumentError)
#    end
#    it "should handle a file not existing and return nil" do
#      lambda {S3Interface.retrieve_from_s3('file.jpg')}.should_not raise_error
#      S3Interface.retrieve_from_s3('file.jpg').should == nil
#    end
#    it "should return a url for an existing file" do
#      lambda {S3Interface.retrieve_from_s3('public/images/FMi.jpg')}.should_not raise_error
#      S3Interface.retrieve_from_s3('public/images/FMi.jpg').should =~ /http/
#    end
#  end
#end