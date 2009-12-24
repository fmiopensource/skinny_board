require File.dirname(__FILE__) + '/../spec_helper'

require 'lib/string.rb'

describe String do
  
  describe "to_html" do
    
    it "should textilize" do
      s = "I'm *bold* and _italic'd_"
      s.to_html.should == "<p>I&#8217;m <strong>bold</strong> and <em>italic&#8217;d</em></p>"
    end

    describe "should convert to a bool properly" do

      it "if \"true\" is passed in" do
        "true".to_bool.should be_true
      end

      it "if \"false\" is passed in" do
        "false".to_bool.should be_false
      end

    end

  end
  
end