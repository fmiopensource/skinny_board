require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User do
#   before(:each) do
#     @valid_attributes = {
#       :first_name => 'John',
#       :last_name => 'Smith',
#       :email => 'john@smith.com',
#       :password => 'john',
#       :password_confirmation => 'john',
#       :company_id => 0,
#       :login => 'jsmith',
#       :avatar_url => "google.ca",
#       :invited_code => "fds234"
#     }
#   end
# 
#   it "should create a new instance given valid attributes" do
#     User.create!(@valid_attributes)
#   end
#   
#   it "should return is invited to true" do
#     user = User.create(@valid_attributes)
#     user.is_invited?.should == true
#   end
#   
#   it "should return is invited to false" do
#     user = User.create(@valid_attributes)
#     
#     user.invited_code = ""
#     user.is_invited?.should == false
# 
#     user.invited_code = nil
#     user.is_invited?.should == false    
#   end  
#   
#   it "should genenrate an invite code" do
#     user = User.create(@valid_attributes)
# 
#     user.invited_code = nil
#     user.generate_invite_code
#     
#     user.invited_code.should_not == nil
#     
#   end
#   
#   it "should validate the invite code" do
#     user = User.create(@valid_attributes)
#     
#     invite_code = user.generate_invite_code
#     user.save!
#     
#     user.invited_code.should == invite_code
#     
#   end
#   
#   
#   it "should return a correct full name" do
#     user = User.create(@valid_attributes)
#     
#     user.full_name.should == "John Smith"
#     
#     user.last_name = nil
#     
#     user.full_name.should == "John"
#   end
#   
#   it "should return a correct avatar" do
# #    '/images/default_avatar.gif'
#     user = User.create(@valid_attributes)
#     
#     user.avatar.should == "google.ca"
#     
#     user.avatar_url = nil
#     user.avatar.should == DEFAULT_AVATAR    
#   end
#   
#   it "should set avatar url appropriately" do
#     user = User.create(@valid_attributes)
#        
#     user.upload_avatar(nil, false)
#     user.avatar_url.should == "google.ca"
#     
#     user.upload_avatar("img.jpg", true)
#     user.avatar_url.should be_nil
#     
#     user.avatar_url = "a url"
#     user.upload_avatar(nil, true)
#     user.avatar_url.should be_nil
#     
#   end
#   
#   describe 'checking if the user owns the company of an element' do
#     
#     it 'should return false if the user is not the company owner' do
#       user = User.new(:id => 1)
#       user.company = mock_model(Company, :owner_id => 9)
#       user.is_company_owner?(1).should be_false
#     end
#     
#     it "'should be false if they're the owner of the company, but the element does not belong to that company" do
#       user = User.new(:id => 1)
#       user.should_receive(:id).and_return(1)
#       user.company = mock_model(Company, :id => 3, :owner_id => 1)
#       
#       @other_user = mock_model(User, :company_id => 4)
#       @element = Element.new
#       @element.creator = @other_user
#       Element.stub!(:find).and_return(@element)
#       
#       user.is_company_owner?(1).should be_false
#     end
#     
#     it "should be true if they're the owner of the company that the element belong to" do
#       user = User.new
#       user.should_receive(:id).and_return(1)
#       user.company = mock_model(Company, :id => 3, :owner_id => 1)
#       
#       @other_user = mock_model(User, :company_id => 3)
#       @element = Element.new
#       @element.creator = @other_user
#       Element.stub!(:find).and_return(@element)
#       
#       user.is_company_owner?(1).should be_true
#     end
#     
#   end
# 
#   describe 'deleting should be logical by setting deleted_at' do
#   
#   end
#   
#   describe "duplicate logins" do
#     it "should allow duplicate logins with different company ids" do
#       user_1 = User.create(@valid_attributes.merge(:login => "trogdor", :company_id => 5))
#       user_1.should be_valid
#       
#       user_2 = User.create(@valid_attributes.merge(:login => "trogdor", :company_id => 6))
#       user_2.should be_valid
#     end
#     
#     it "should not allow duplicate logins with the same company id" do
#       user_1 = User.create(@valid_attributes.merge(:login => "trogdor", :company_id => 5))
#       user_1.should be_valid
#       
#       user_2 = User.create(@valid_attributes.merge(:login => "trogdor", :company_id => 5))
#       user_2.should_not be_valid
#     end
#   end
end
