require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => "users", :action => "index").should == "/users"
    end
  
    it "should map #new" do
      route_for(:controller => "users", :action => "new").should == "/users/new"
    end
  
    it "should map #show" do
      route_for(:controller => "users", :action => "show", :id => "1").should == "/users/1"
    end
  
    it "should map #edit" do
      route_for(:controller => "users", :action => "edit", :id => "1").should == "/users/1/edit"
    end
  
    it "should map #update" do
      route_for(:controller => "users", :action => "update", :id => "1").should == {:path => "/users/1", :method => :put}
    end
  
    it "should map #destroy" do
      route_for(:controller => "users", :action => "destroy", :id => "1").should == {:path => "/users/1", :method => :delete}
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, "/users").should == {:controller => "users", :action => "index"}
    end
  
    it "should generate params for #new" do
      params_from(:get, "/users/new").should == {:controller => "users", :action => "new"}
    end
  
    it "should generate params for #create" do
      params_from(:post, "/users").should == {:controller => "users", :action => "create"}
    end
  
    it "should generate params for #show" do
      params_from(:get, "/users/1").should == {:controller => "users", :action => "show", :id => "1"}
    end
  
    it "should generate params for #edit" do
      params_from(:get, "/users/1/edit").should == {:controller => "users", :action => "edit", :id => "1"}
    end
  
    it "should generate params for #update" do
      params_from(:put, "/users/1").should == {:controller => "users", :action => "update", :id => "1"}
    end
  
    it "should generate params for #destroy" do
      params_from(:delete, "/users/1").should == {:controller => "users", :action => "destroy", :id => "1"}
    end
  end
end
