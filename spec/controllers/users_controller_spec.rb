require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UsersController do
  include AuthenticatedTestHelper
  fixtures :users, :companies
  
  def mock_user(stubs={})
    @mock_user ||= mock_model(User, stubs)
  end
  
  def mock_company(stubs={})
    @mock_company ||= mock_model(Company, stubs.merge({:users => [@mock_user], :needs_to_pay => false}))
  end
  
  def mock_payment(stubs={})
    @mock_payment ||= mock_model(PaymentPlan, stubs)
  end
  
  describe "responding to GET index" do
    before :each do
      login_as("quentin")
    end
      
    it "should expose all users as @users" do
      mock_user.stub!(:avatar).and_return(DEFAULT_AVATAR)
      mock_user.stub!(:company).and_return(mock_company)
      User.should_receive(:paginate).with({:per_page => 15, :conditions=>["company_id = ?", 1], :page => 1}).and_return([mock_user])
      get :index
      assigns[:users].should == [mock_user]
    end


  end

  describe "responding to GET show" do
    before :each do
      User.stub!(:find_by_id).and_return(users(:quentin))
      login_as("quentin")
    end
    
    it "should expose the requested user as @user" do
      User.should_receive(:find).with("37").and_return(mock_user)
      get :show, :id => "37"
      assigns[:user].should equal(mock_user)
    end
    
  end

  describe "responding to GET new" do
  
    before(:each) do
      
    end
    
    it "should expose a new user as @user" do
      User.should_receive(:new).and_return(mock_user)
      Company.should_receive(:new).and_return(mock_company)
      get :new
      assigns[:user].should equal(mock_user)
      assigns[:company].should equal(mock_company)
    end

  end

  describe "responding to GET edit" do
    before :each do
      User.stub!(:find_by_id).and_return(users(:quentin))
      login_as("quentin")
    end
    it "should expose the requested user as @user" do
      User.should_receive(:find).with("37").and_return(mock_user(:twitter_password => ""))
      get :edit, :id => "37"
      assigns[:user].should equal(mock_user)
    end
  end

  describe "responding to POST /users" do
    
    def do_post
      post :create, {:user => {:first_name => 'joe'}, :company => {:name => 'FMI', 'subdomain' => 'fmitest1'}}
    end
    
    describe "with valid params" do
      
      before :each do
        mock_company.stub!(:valid?).and_return(true)
        mock_company.stub!(:save).with(false).and_return(true)
        mock_company.stub!(:users).and_return([mock_user])
        mock_company.should_receive(:owner_id=)
        mock_company.should_receive(:company_status_id=).with(1)
        mock_company.stub!(:subdomain).and_return('fmitest1')
        mock_company.stub!(:subdomain=)
        mock_company.stub!(:needs_to_pay=)
        mock_company.stub!(:name=)
        

        mock_user.stub!(:valid?).and_return(true)
        mock_user.stub!(:save).with(false).and_return(true)
        mock_user.stub!(:upload_avatar)
        mock_user.should_receive(:invited_code=).with(nil)
        mock_user.should_receive(:activate)
        mock_user.stub!(:first_name).and_return('joe')
        mock_user.stub!(:company)
        mock_user.stub!(:company=)

        Company.should_receive(:new).with({'name' => 'FMI', 'subdomain' => 'fmitest1'}).and_return(mock_company)
        User.should_receive(:new).with('first_name' => 'joe', 'invited_code' => 'creating company').and_return(mock_user)
      end
      
      it "should expose a newly created user & company as @user & @company" do
        mock_company.stub!(:update_attributes)
        do_post
        assigns(:user).should equal(mock_user)
        assigns(:company).should equal(mock_company)
      end      
    end
    
    describe "with invalid params" do

      before :each do
        mock_company.stub!(:valid?).and_return(false)
        mock_user.stub!(:valid?).and_return(false)
        mock_user.stub!(:first_name).and_return('joe')
        Company.should_receive(:new).with({'name' => 'FMI', 'subdomain' => 'fmitest1'}).and_return(mock_company)
        User.should_receive(:new).with('first_name' => 'joe', 'invited_code' => 'creating company').and_return(mock_user)
        mock_user.should_receive(:invited_code=)
        mock_company.errors.stub!(:each)
        mock_company.stub!(:subdomain)
        mock_company.stub!(:subdomain=)
        mock_company.stub!(:name=)
      end
      
      it "should expose a newly created but unsaved user as @user" do
        User.stub!(:new).with({'first_name' => 'joe'}).and_return(mock_user(:save => false))
        mock_user.stub!(:save).and_return(mock_user(:save => false))
        do_post
        assigns(:user).should equal(mock_user)
      end

      it "should re-render the 'new' template" do
        do_post
        response.should be_success
        response.should render_template('new')
      end
      
    end
    
  end

  describe "responding to PUT udpate" do
    before :each do
      mock_user.stub!(:upload_avatar)
    end
    describe "with valid params" do
      before :each do
        mock_user.stub!(:update_attributes).and_return(true)
        mock_user.stub!(:save!)
      end
      it "should update the requested user" do
        User.should_receive(:find).with("37").and_return(mock_user)                
        mock_user.should_receive(:update_attributes).with({'these' => 'params'})
        mock_user.should_receive(:invited_code=).with("")
        
        put :update, :id => "37", :user => {:these => 'params'}
      end

      it "should expose the requested user as @user" do
        User.stub!(:find).and_return(mock_user(:update_attributes => true))
        mock_user.should_receive(:invited_code=).with("")
        put :update, :id => "1"
        assigns(:user).should equal(mock_user)
      end

      it "should redirect to the user" do
        User.stub!(:find).and_return(mock_user(:update_attributes => true))
        mock_user.should_receive(:invited_code=).with("")        
        put :update, :id => "1"
        response.should redirect_to(users_url)
      end

    end
    
    describe "with invalid params" do
      before :each do
        mock_user.stub!(:update_attributes).and_return(false)
      end
      
      it "should update the requested user" do
        User.should_receive(:find).with("37").and_return(mock_user)
        mock_user.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :user => {:these => 'params'}
      end

      it "should expose the user as @user" do
        User.stub!(:find).and_return(mock_user(:update_attributes => false))
        put :update, :id => "1"
        assigns(:user).should equal(mock_user)
      end

      it "should re-render the 'edit' template" do
        User.stub!(:find).and_return(mock_user(:update_attributes => false))
        put :update, :id => "1"
        response.should render_template('edit')
      end

    end

  end

  describe "responding to DELETE destroy" do

    it "should destroy the requested user" do
      User.should_receive(:find).with("37").and_return(mock_user)
      mock_user.should_receive(:destroy)
      delete :destroy, :id => "37"
    end
  
    it "should redirect to the users list" do
      User.stub!(:find).and_return(mock_user(:destroy => true))
      delete :destroy, :id => "1"
      response.should redirect_to(users_url)
    end

  end

end
