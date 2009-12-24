require File.dirname(__FILE__) + '/../spec_helper'

describe FiltersController do
  include AuthenticatedTestHelper
  fixtures :users, :companies

  # describe "handling POST /filters" do
  # 
  #   before(:each) do
  #     login_as(:quentin)
  #     UserBoardFilter.stub!(:add_story_filter)
  #     UserBoardFilter.stub!(:add_status_filter)
  #     creator = mock_model(User, :id => 2, :company_id => 1)
  #     @board = mock_model(Element, :id => 1, :creator => creator)
  #     Element.stub!(:find).and_return([@board])
  #   end
  # 
  #   describe "with successful save of stories" do
  # 
  #     def do_post
  #       post :create, :story_id => "1", :is_open => "true", :board_id => @board.id
  #     end
  # 
  #     it "should call add_story_filter with the proper variables" do
  #       UserBoardFilter.should_receive(:add_story_filter).with("1", users(:quentin).id, "true", @board.id.to_s)
  #       do_post
  #       response.should have_text("OK")
  #     end
  # 
  #   end
  # 
  #   describe "with successful save of statuses" do
  # 
  #     def do_post
  #       post :create, :status_id => "1", :is_open => "true", :board_id => "2"
  #     end
  # 
  #     it "should call add_story_filter with the proper variables" do
  #       UserBoardFilter.should_receive(:add_status_filter).with("1", users(:quentin).id, "2", "true")
  #       do_post
  #       response.should have_text("OK")
  #     end
  # 
  #   end
  # 
  #   describe "with successful save of a filter" do
  # 
  #     def do_post
  #       post :create, :text_filter => "abc", :board_id => "2"
  #     end
  # 
  #     it "should call add_text_filter with the proper variables" do
  #       UserBoardFilter.should_receive(:add_text_filter).with("abc", users(:quentin).id, "2")
  #       do_post
  #       response.should have_text("OK")
  #     end
  # 
  #   end
  # 
  # end
  # 
  # describe "handling POST /filters when not logged in" do
  # 
  #   before(:each) do
  #     UserBoardFilter.stub!(:add_story_filter)
  #     UserBoardFilter.stub!(:add_status_filter)
  #     creator = mock_model(User, :id => 2, :company_id => 1)
  #     @board = mock_model(Element, :id => 1, :creator => creator, :is_public => true)
  #     Element.stub!(:find).and_return([@board])
  #   end
  # 
  #   def do_post
  #     post :create, :board_id => "1"
  #   end
  # 
  #   it "should return 'PUBLIC' for a public board" do
  #     do_post
  #     response.should have_text("PUBLIC")
  #   end
  # 
  # end

end