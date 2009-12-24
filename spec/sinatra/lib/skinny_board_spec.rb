require File.dirname(__FILE__) + '/../../spec_helper'
require "#{RAILS_ROOT}/app/sinatra/lib/couch/couch"
require "#{RAILS_ROOT}/app/sinatra/lib/skinny_board"
require "#{RAILS_ROOT}/spec/sinatra/fixtures/fixture"

class TestBoard
  extend Couch::DB
  extend SkinnyBoard::Boards
end

describe TestBoard do
  before do
    TestBoard.stub!(:current_company).and_return(COUCHDB_TEST_DB[1..-1])
    TestBoard.stub!(:current_user).and_return(1) #must be set to a value in the document
    @board = FactoryBoy.create(Fixture.board(0, :level => LEVEL_BOARD))
  end
  
  describe "reorder_stories" do
    it "should reorder the stories based on priority" do
      # removes the first story from the array
      @board.stories.replace(@board.stories.drop(1))
      @board.stories.first.position.should == 2
      TestBoard.reorder_stories(@board)
      
      @board.stories.first.position.should == 1
    end
  end

  describe "hours remaining" do
    it "should not count the hours for done tasks" do
      @board["stories"][0]["tasks"][0]["status_id"]=2 # in process
      @board["stories"][0]["tasks"][0]["hours"]=5.0 
      @board["stories"][1]["tasks"][0]["status_id"]=4 # done
      @board["stories"][1]["tasks"][0]["hours"]=1.0 
      TestBoard.update_board(@board, :add_up_tasks => true)
      @board.hours.should==5.0
    end
  end

  describe "getting all boards for a company" do
    before do
      @board2 = FactoryBoy.create(Fixture.board(0, :level => LEVEL_BOARD))
      @board3 = FactoryBoy.create(Fixture.board(0, :level => LEVEL_BOARD))
    end
    
    it "should get all boards sorted by last edited time ascending" do
      @boards = TestBoard.get_boards.map{ |b| TestBoard.get_board(b._id) }
      @boards.map { |b|
        sleep(2)
        TestBoard.update_board(b)
      } # this should fix the updated at time
      @boards = TestBoard.get_boards.map{ |b| {:id => b.id}.merge(b.value) }
      @boards.map! { |b| {:id => b.id, :updated_at => b.updated_at } }
      @boards.should == @boards.sort_by { |b| b[:updated_at] }
    end

  end
end
