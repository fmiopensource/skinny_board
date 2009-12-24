require File.dirname(__FILE__) + '/../spec_helper'

describe UserBoardFilter do

  # describe "adding a filter for stories" do
  # 
  #   before(:each) do
  #     @story_id = 1
  #     @user_id  = 2
  #     @board_id = 3
  #     @story = mock_model(Element, :id => @story_id, :parent_id => @board_id)
  #     Element.stub!(:find).and_return(@story)
  #   end
  # 
  #   def call_add_story_filter(params={})
  #     params[:story_id] ||= @story_id
  #     params[:user_id]  ||= @user_id
  #     params[:is_open] =  params[:is_open].nil? ? true : params[:is_open]
  #     params[:filter]   ||= nil
  # 
  #     @ubf = mock_model(UserBoardFilter, :user_id => @user_id, :board_id => @board_id, :filters => params[:filter])
  #     @ubf.stub!(:filters=)
  #     #@ubf.stub!(:save).and_return(true)
  #     @ubf.should_receive(:save).and_return(true)
  #     UserBoardFilter.stub!(:find_or_create_by_board_id_and_user_id).and_return(@ubf)
  # 
  #     UserBoardFilter.should_receive(:find_or_create_by_board_id_and_user_id).with(@board_id, @user_id)
  # 
  #     UserBoardFilter.add_story_filter(params[:story_id], params[:user_id], params[:is_open], @board_id)
  #   end
  # 
  #   it "should not add the story when opening if there is no story in there already" do
  #     current_filters = { :closed_stories => { '123' => 1, '456' => 1 } }.to_yaml
  #     new_filters = call_add_story_filter(:filter => current_filters)
  #     new_filters[@story_id].should be_nil
  #   end
  # 
  #   it "should remove the story when opening if the story exists in the hash" do
  #     current_filters = { :closed_stories => { '123' => 1, '456' => 1, @story_id => 1 } }.to_yaml
  #     new_filters = call_add_story_filter(:filter => current_filters)
  #     new_filters[@story_id].should be_nil
  #   end
  # 
  #   it "should add the story to the hash when closing" do
  #     current_filters = { :closed_stories => { '123' => 1, '456' => 1 } }.to_yaml
  #     new_filters = call_add_story_filter(:filter => current_filters, :is_open => false)
  #     new_filters[:closed_stories][@story_id.to_s].should == 1
  #   end
  # 
  # end
  # 
  # describe "adding a filter for statuses" do
  # 
  #   before(:each) do
  #     @status_id = 1
  #     @user_id  = 2
  #     @board_id = 3
  #   end
  # 
  #   def call_add_status_filter(params={})
  #     params[:status_id] ||= @status_id
  #     params[:user_id]   ||= @user_id
  #     params[:filter]    ||= nil
  #     params[:is_open]   =  params[:is_open].nil? ? true : params[:is_open]
  # 
  #     @ubf = mock_model(UserBoardFilter, :user_id => params[:user_id], :board_id => @board_id, :filters => params[:filter])
  #     @ubf.stub!(:filters=)
  #     @ubf.should_receive(:save).and_return(true)
  # 
  #     UserBoardFilter.stub!(:find_or_create_by_board_id_and_user_id).and_return(@ubf)
  #     UserBoardFilter.should_receive(:find_or_create_by_board_id_and_user_id).with(@board_id, @user_id)
  #     UserBoardFilter.add_status_filter(params[:story_id], params[:user_id], @board_id, params[:is_open])
  #   end
  # 
  #   it "should not add the status when opening if there is no status in there already" do
  #     current_filters = { :closed_columns => { '1' => 1, '2' => 1 } }.to_yaml
  #     new_filters = call_add_status_filter(:filter => current_filters)
  #     new_filters[@story_id].should be_nil
  #   end
  # 
  #   it "should remove the story when opening if the story exists in the hash" do
  #     current_filters = { :closed_columns => { '1' => 1, '2' => 1, @story_id => 1 } }.to_yaml
  #     new_filters = call_add_status_filter(:filter => current_filters)
  #     new_filters[@story_id].should be_nil
  #   end
  # 
  #   it "should add the story to the hash when closing" do
  #     current_filters = { :closed_columns => { '1' => 1, '2' => 1 } }.to_yaml
  #     new_filters = call_add_status_filter(:filter => current_filters, :is_open => false)
  #     new_filters[:closed_columns][@story_id.to_s].should == 1
  #   end
  # 
  # end
  # 
  # describe "adding a filter for text" do
  # 
  #   before(:each) do
  #     @text = "abc"
  #     @user_id  = 2
  #     @board_id = 3
  #   end
  # 
  #   def call_add_text_filter(params={})
  #     params[:text]      ||= @text
  #     params[:user_id]   ||= @user_id
  #     params[:filter]    ||= nil
  # 
  #     @ubf = mock_model(UserBoardFilter, :user_id => params[:user_id], :board_id => @board_id, :filters => params[:filter])
  #     @ubf.stub!(:filters=)
  #     @ubf.should_receive(:save).and_return(true)
  # 
  #     UserBoardFilter.stub!(:find_or_create_by_board_id_and_user_id).and_return(@ubf)
  #     UserBoardFilter.should_receive(:find_or_create_by_board_id_and_user_id).with(@board_id, @user_id)
  # 
  #     UserBoardFilter.add_text_filter(params[:text], params[:user_id], @board_id)
  #   end
  # 
  #   it "should save the text filter if there's no filter to begin with" do
  #     current_filters = { :text_filter => '' }.to_yaml
  #     new_filters = call_add_text_filter(:filter => current_filters)
  #     new_filters[:text_filter].should == 'abc'
  #   end
  # 
  #   it "should save the text filter over the previous filter" do
  #     current_filters = { :text_filter => 'def' }.to_yaml
  #     new_filters = call_add_text_filter(:filter => current_filters)
  #     new_filters[:text_filter].should == 'abc'
  #   end
  # 
  # end

end
