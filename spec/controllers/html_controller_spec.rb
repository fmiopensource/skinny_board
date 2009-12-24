require File.dirname(__FILE__) + '/../spec_helper'

describe HtmlController do

  describe "responding to all the requests" do

    def do_get(action)
      get action
    end

    it "be a success" do
      [:faq, :legal, :privacypolicy, :termsofservice].each do |action|
        do_get(action)
        response.should be_success
      end
    end

    it "should render the proper view" do
      [:faq, :legal, :privacypolicy, :termsofservice].each do |action|
        do_get(action)
        response.should render_template(action.to_s)
      end
    end
  end
end