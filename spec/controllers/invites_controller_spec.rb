require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe InvitesController do
  include AuthenticatedTestHelper
  
  describe "responding to PUT /invites/:id" do
    
    before(:each) do 
      @company = mock_model(Company)
      @user = mock_model(User, :invited_code => "123", :login => "tdurden", :password => "psw", :company_id => @company.id, :first_name => "Tyler", :last_name => "Durden")
      User.stub!(:find).and_return(@user)
      User.stub!(:authenticate).and_return(@user)
    end
    
    describe "with valid params" do
      it "should redirect to the users_path(@user)" do
        @user.stub!(:update_attributes).and_return(true)
        @user.should_receive(:invited_code=).with("")
        @user.should_receive(:activated_at=)
        @user.should_receive(:save!)
        @user.stub!(:upload_avatar)
        put :update, :id => 1
        flash[:notice].should_not be_nil
        response.should redirect_to(user_path(@user))
      end
    end
    
    describe "with invalid params" do
      it "should re-render the new action in the users controller" do
        @user.stub!(:update_attributes).and_return(false)
        put :update, :id => 1
        response.should render_template("users/new")
      end
    end
  end
end