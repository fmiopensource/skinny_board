require File.dirname(__FILE__) + '/../spec_helper'

describe "Api Boards Controller" do
  include Rack::Test::Methods

  before do
    ApiBoardsController.class_eval do
      helpers do
        def authorize
          return true
        end

        def get_board_revision(id)
          return 5544
        end

        def get_users(id)
          return ["Dan", "Bart", "Chelsea"]
        end

        def get_board(id)
          {:burndown_image_path => "ff.jpg"}
        end
      end
    end
  end

  describe "board api functions" do
    it "should do a ger request" do
      get '/api/boards/frade_test/4'

      last_response.should be_ok
    end

    it "shoud get '/api/boards/:id/revision'" do
      get '/api/boards/5544/revision'

      last_response.body.should == "{\"ok\":true,\"revision\":5544}"
    end

    it "should get '/api/boards/:id/users'" do
      get '/api/boards/5544/users'

      last_response.body.should == "{\"ok\":true,\"users\":[\"Dan\",\"Bart\",\"Chelsea\"]}"
    end

    it "should get '/api/boards/:id/burndown'" do

#      controller.should_receive(:get_board).and_return({:burndown_image_path => "ff.jpg"})
      get '/api/boards/:id/burndown'

      last_response.body.should == "{\"ok\":true,\"burndown\":{\"image_path\":\"ff.jpg\"}}"
    end

  end

end
