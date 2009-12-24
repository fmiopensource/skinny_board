require File.dirname(__FILE__) + '/../spec_helper'

describe AccountController do
  include AuthenticatedTestHelper
  fixtures :users, :companies
  
  describe "with successful login" do
    before(:each) do
      User.stub!(:authenticate).and_return(users(:quentin))
      Company.should_receive(:find_by_subdomain).and_return(mock_model(Company))
    end
    
    it "should login and redirect" do
      post :login, :login => 'quentin', :password => 'voltron'
      assert session[:user]
      response.should be_redirect
    end

    it "should remember me" do
      post :login, :login => 'quentin', :password => 'voltron', :remember_me => "1"
      response.cookies["auth_token"].should_not be_nil
    end
    
    it "should not remember me" do
      post :login, :login => 'quentin', :password => 'voltron', :remember_me => "0"
      response.cookies["auth_token"].should be_nil
    end
    
  end

  it "should not redirect on a failed login" do
    User.stub!(:authenticate).and_return(nil)
    post :login, :login => 'quentin', :password => 'test'
    session[:user].should be_nil
    response.should be_success
  end
  
  it "should not log in without a subdomain" do
    Company.should_receive(:find_by_subdomain).and_return(nil)
    User.should_receive(:authenticate).exactly(0).times
    post :login, :login => 'quentin', :password => 'test'
    session[:user].should be_nil
    response.should be_success
    flash[:notice].should == "You must log in from your subdomain."
  end

  
  describe "when logging out" do
    before(:each) do
      login_as :quentin  
    end
    
    it "should destroy the session and redirect" do
      get :logout

      session[:user].should be_nil
      response.should be_redirect  
    end
    
    it "should delete the token" do
      get :logout
      response.cookies["auth_token"].should be_nil
    end
      
  end
  
  describe "when dealing with cookies" do
    before(:each) do
      users(:quentin).remember_me
    end
    it "should login from a cookie" do
      request.cookies["auth_token"] = cookie_for(:quentin)
      get :login
      session[:user].should_not be_nil
    end

    it "should fail to login with an expired cookie" do
      users(:quentin).update_attribute :remember_token_expires_at, 5.minutes.ago
      request.cookies["auth_token"] = cookie_for(:quentin)

      get :login
      session[:user].should be_nil
    end
    
    it "should fail to login with an invalid cookie" do
      request.cookies["auth_token"] = auth_token("invalid_token")
      get :login
      session[:user].should be_nil
    end
  end
  
  describe "when activating an account" do
    
    it "should require an activation code" do
      get :activate, :activation_code => nil      
      response.should be_redirect
    end
    
    it "should require a valid activation code" do
      get :activate, :activation_code => "abcdefg"
      response.should be_redirect
    end
    
    it "should activate a user" do 
      users(:quentin).update_attribute(:activated_at, nil )
      users(:quentin).update_attribute(:activation_code, Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join ) )

      get :activate, :id => users(:quentin).activation_code 

      response.should be_redirect
    end

  end

  describe "when resetting a password" do
    before(:each) do
      ActionMailer::Base.deliveries = []
    end
    
    it "should require a subdomain" do
      Company.should_receive(:find_by_subdomain).and_return(nil)
      User.should_receive(:find).exactly(0).times
      post :forgot_password, :email => 'invalid@example.com'
      response.should be_success
      sent.length.should == 0      
    end
    
    it "should forget a password with a valid email" do
      Company.should_receive(:find_by_subdomain).and_return(mock_model(Company))
      @user = users(:quentin)
      User.should_receive(:find).and_return(@user)
      post :forgot_password, :email => 'quentin@example.com'    
      
      response.should be_redirect
      flash[:notice].should_not be_nil
      sent.length.should == 1
      sent.first.subject =~ /password/
    end
    
    it "should not forget a password for an invalid address" do
      Company.should_receive(:find_by_subdomain).and_return(mock_model(Company))
      User.should_receive(:find).and_return(nil)
      post :forgot_password, :email => 'invalid@example.com'
      response.should be_success
      sent.length.should == 0
    end

    describe "getting user input to reset password" do
      before(:each) do
        @user = users(:quentin)
        @user.forgot_password && @user.save
        User.stub!(:find_by_password_reset_code).and_return(@user)
        sent.clear
      end
      
      it "should require a subdomain" do
        Company.should_receive(:find_by_subdomain).and_return(nil)
        User.should_receive(:find).exactly(0).times
        post :reset_password, :id => @user.id, :password => "new_pass", :password_confirmation => "new_pass"
        response.should be_success
        sent.length.should == 0      
      end
      
      it "should require a valid reset code" do
        Company.should_receive(:find_by_subdomain).and_return(mock_model(Company))
        User.stub!(:find_by_password_reset_code).and_return(nil)
        post :reset_password, :id => @user.id, :password => "new_pass", :password_confirmation => "new_pass"
        flash[:notice].should == "Sorry - That is an invalid password reset code. Please check your code and try again. (Perhaps your email client inserted a carriage return?"
      end

      it "should reset the password given a valid code and password" do        
        Company.should_receive(:find_by_subdomain).and_return(mock_model(Company))
        @user.stub!(:recently_forgot_password?).and_return(false)
        post :reset_password, :reset_code => @user.password_reset_code, :password => "new_pass", :password_confirmation => "new_pass"

        flash[:notice].should == "Password has been reset."
        @user.recently_reset_password?.should be_true
      end
      
      it "should send an email if the password has been reset" do
        Company.should_receive(:find_by_subdomain).and_return(mock_model(Company))
        @user.stub!(:recently_forgot_password?).and_return(false)
        @user.stub!(:recently_reset_password?).and_return(true)
        
        post :reset_password, :reset_code => @user.password_reset_code, :password => "new_pass", :password_confirmation => "new_pass"
        
        sent.length.should == 1
      end

      it "should not reset the password with a valid code and unmatched password" do
        Company.should_receive(:find_by_subdomain).and_return(mock_model(Company))
        post :reset_password, :reset_code => @user.password_reset_code, :password => "new_pass", :password_confirmation => "yarr"

        @user.errors.should_not be_nil
        @user.recently_reset_password?.should be_false
      end
      
      it "should not send an email if the password has not been reset" do
        Company.should_receive(:find_by_subdomain).and_return(mock_model(Company))
        @user.stub!(:recently_forgot_password?).and_return(false)
        @user.stub!(:recently_reset_password?).and_return(false)
        
        post :reset_password, :reset_code => @user.password_reset_code, :password => "new_pass", :password_confirmation => "yarr"
        
        sent.length.should == 0
      end
      
    end
    
    
    def sent
      ActionMailer::Base.deliveries
    end
  end 
  
  protected
    def create_user(options = {})
      post :signup, :user => { :login => 'quire', :email => 'quire@example.com', 
        :password => 'quire', :password_confirmation => 'quire', :first_name => 'Quire',
        :last_name => 'Shire' }.merge(options)
    end
    
    def auth_token(token)
      CGI::Cookie.new('name' => 'auth_token', 'value' => token)
    end
    
    def cookie_for(user)
      auth_token users(user).remember_token
    end
end
