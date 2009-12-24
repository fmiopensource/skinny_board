require File.dirname(__FILE__) + '/../spec_helper'

describe "Sinatra Users Controller" do
  include Rack::Test::Methods

  before(:all) do
    User.stub!(:find_by_id_and_company_id).and_return({"id" => 1, "full_name" => "user one"})


    SinatraUsersController.class_eval do
      helpers do
        def authorize
          return true
        end
        def get_board(id, options={})
          return {"users" => [
            {"id" => 1, "name" => "user one"},
            {"id" => 2, "name" => "user two"}
          ]}
        end
        def save_board(board, options={})
          response['board'] = board
        end
        def current_company
          return 5
        end
        def login_required
          nil
        end
        def authorization_required(id)
          nil
        end
      end
    end

  end

  describe 'when adding users to a board' do
    it 'should move from available to access' do
      User.stub!(:find_by_id_and_company_id).and_return({"id" => 3, "full_name" => "user three"})
      put '/boards/999/users/3'
      last_response.body.should == {
        "ok" => true,
        "user" => {"id" => 3, "name" => "user three"}
      }.to_json

      last_response['board']['users'].select{ |u| u[:id] == 3
      }.should == [{:id => 3, :name => "user three"}]
    end
    it 'should only add users that are in the company' do
      User.stub!(:find_by_id_and_company_id).and_return(nil)
      put '/boards/999/users/999'
      last_response.body.should ==  {
        "ok" => false,
        "error" => "User not found."
      }.to_json
    end
    it 'should require an integer user id' do
      put "/boards/999/users/abcd"
      last_response.body.should ==  {
        "ok" => false,
        "error" => "User id not provided."
      }.to_json
    end
    it 'should only add users without access' do
      put '/boards/999/users/1'
      last_response.body.should ==  {
        "ok" => false,
        "error" => "User already in the list."
      }.to_json
    end
  end
  describe 'when deleting users from a board' do
    before do
      Company.stub!(:find_by_id).and_return({"owner_id" => 2})
    end
    it 'should require an integer user id' do
      delete "/boards/999/users/abcd"
      last_response.body.should ==  {
        "ok" => false,
        "error" => "User id not provided."
      }.to_json
    end
    it 'should move from access to available' do
      delete "/boards/999/users/1"
      last_response.body.should == {
        "ok" => true
      }.to_json
      last_response['board']['users'].select{|u|
        u["id"] == 1}.should == []
    end
    it 'should not remove the company owner' do
      
      delete "/boards/999/users/2"
      last_response.body.should ==  {
        "ok" => false,
        "error" => "Can't delete company owner."
      }.to_json
    end
    it 'should only remove users with access' do
      delete "/boards/999/users/999"
      last_response.body.should ==  {
        "ok" => false,
        "error" => "User is not in the list."
      }.to_json
    end
  end
end

