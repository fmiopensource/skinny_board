require File.dirname(__FILE__) + '/../../spec_helper'
require "#{RAILS_ROOT}/app/sinatra/lib/helpers/api_helper"

class TestApiHelper
  extend Helpers::API
end

describe TestApiHelper do
  before(:each) do
    TestApiHelper.stub!(:response).and_return(Hash.new)
    @board_head = {"id" => 999, "parent_id" => 999}
    @board_not_head = {"id" => 999, "parent_id" => 666}
    TestApiHelper.stub!(:params).and_return({:id => "999"})
  end
  describe 'cud_wrapper with access' do
    before(:each) do
      TestApiHelper.stub!(:logged_in?).and_return(true)
      TestApiHelper.stub!(:authorized?).and_return(true)
    end
    it 'should only allow HEAD board updates' do
      ->{TestApiHelper.cud_wrapper(@board_not_head){|board|
          board}}.should raise_error(ArgumentError, 'uncaught throw :halt')
    end
    it 'should allow HEAD board updates' do
      ->{TestApiHelper.cud_wrapper(@board_head){|board|
          board}}.should_not raise_error
    end
  end
  describe 'cud_wrapper with no access' do
    before(:each) do
      TestApiHelper.stub!(:logged_in?).and_return(false)
      TestApiHelper.stub!(:authorized?).and_return(false)
    end
    it 'should not allow unauthorized access' do
      ->{TestApiHelper.cud_wrapper(@board_head){|board|
          board}}.should raise_error
    end
  end
end