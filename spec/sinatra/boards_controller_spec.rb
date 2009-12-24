require File.dirname(__FILE__) + '/../spec_helper'

describe SinatraBoardsController do
  include Rack::Test::Methods

  before(:all) do
   SinatraUsersController.class_eval do
      helpers do
        def current_company
          return 5
        end
        def current_subdomain
          return "test"
        end
        def login_required
          nil
        end
        def authorization_required(id)
          nil
        end
        def boards_viewed_add(id, title)
          nil
        end
      end
    end
  end

  describe 'when viewing a private board' do
    before(:all) do
      SinatraUsersController.class_eval do
        helpers do
          def get_board(id, options={})
            return {"is_public" => false, "title" => "sure its a board", "level" => 0,
              "id" => "999", "parent_id" => "999", "stories" => [
                {"id" => "233", "title" => "I am a story", "tasks" => [
                  {"id" => "3443", "title" => "I am a task", "status_id" => STATUS_TODO}
                ]}
              ]
            }
          end
        end
      end
    end
    describe 'with full access' do
      before(:all) do
        SinatraUsersController.class_eval do
          helpers do
            def logged_in?
              return true
            end
            def authorized?(id)
              return true
            end
          end
        end

        it 'should display the board' do
          get '/boards/999'
          last_response.should be_ok
        end
        it 'should allow adding stories' do
          get '/boards/999'
          (last_response.body =~ /<a href="#\/stories\/new" >/).should_not == nil
          (last_response.body =~ /<div id="story_new"/).should_not == nil
        end
        it 'should allow editing stories' do
          get '/boards/999'
          (last_response.body =~ /<div id="story_[0-9a-f]+_edit"/).should_not == nil
          (last_response.body =~ /"#\/stories\/[0-9a-f]+\/edit"/).should_not == nil
        end
        it 'should allow adding tasks to stories' do
          get '/boards/999'
          (last_response.body =~ /<a href="#\/stories\/[0-9a-f]+\/tasks\/new">/).should_not == nil
        end
        it 'should allow editing tasks' do
          get '/boards/999'
          (last_response.body =~ /<div id="element_[0-9a-f]+_edit"/).should_not == nil
          (last_response.body =~ /\/tasks\/[0-9a-f]+\/edit/).should_not == nil
        end
      end
    end
  end

  describe 'when viewing a public board' do
    describe 'without being logged in' do
      before(:all) do
        SinatraUsersController.class_eval do
          helpers do
            def get_board(id, options={})
              return {"is_public" => true, "title" => "sure its a board", "level" => 0,
                "id" => "999", "parent_id" => "999", "stories" => [
                  {"id" => "233", "title" => "I am a story", "tasks" => [
                    {"id" => "3443", "title" => "I am a task"}
                  ]}
                ]
              }
            end
             def logged_in?
              return false
            end
            def authorized?(id)
              return false
            end
          end
        end
      end
      it 'should load the board' do
        get '/boards/999'
        last_response.should be_ok
      end
      it 'should not allow adding stories' do
        get '/boards/999'
        (last_response.body =~ /<a href="#\/stories\/new" >/).should == nil
        (last_response.body =~ /<div id="story_new"/).should == nil
      end
      it 'should not allow editing stories' do
        get '/boards/999'
        (last_response.body =~ /<div id="story_[0-9a-f]+_edit"/).should == nil
        (last_response.body =~ /"#\/stories\/[0-9a-f]+\/edit"/).should == nil
      end
      it 'should not allow adding tasks to stories' do
        get '/boards/999'
        (last_response.body =~ /<a href="#\/stories\/[0-9a-f]+\/tasks\/new">/).should == nil
      end
      it 'should not allow editing tasks' do
        get '/boards/999'
        (last_response.body =~ /<div id="element_[0-9a-f]+_edit"/).should == nil
        (last_response.body =~ /#\/stories\/[0-9a-f]+\/tasks\/[0-9a-f]+\/edit/).should == nil
      end
    end
  end
end
