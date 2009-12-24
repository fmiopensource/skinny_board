require File.dirname(__FILE__) + '/../../spec_helper'
require "#{RAILS_ROOT}/app/sinatra/lib/couch/couch"
require "#{RAILS_ROOT}/app/sinatra/lib/skinny_board"
require "#{RAILS_ROOT}/app/sinatra/lib/product_backlog"
require "#{RAILS_ROOT}/spec/sinatra/fixtures/fixture"

class TestProductBacklog
  extend SkinnyBoard::ProductBacklog
  extend Couch::DB
  extend SkinnyBoard::Boards
end

describe TestProductBacklog do
  before do
    TestProductBacklog.stub!(:current_company).and_return(COUCHDB_TEST_DB[1..-1])
    TestProductBacklog.stub!(:current_user).and_return(1) #must be set to a value in the document
    @backlog = FactoryBoy.create(Fixture.board(0, :level => LEVEL_PRODUCT_BACKLOG))
  end

  describe 'when it find_or_create_board' do
    it 'should find board' do
      board = FactoryBoy.create(Fixture.board(0))
      found_board = TestProductBacklog.find_or_create_board(board)
      found_board["_id"].should == board["_id"]
    end

    it 'should create board with no backlog' do
      created_board = TestProductBacklog.find_or_create_board()
      created_board["title"].should_not == nil
      created_board["level"].should == LEVEL_BOARD
    end

    it 'should create board with a backlog and transfer properties' do
      created_board = TestProductBacklog.find_or_create_board({}, @backlog)
      created_board["title"].should_not == nil
      created_board["level"].should == LEVEL_BOARD
      created_board["users"].should == @backlog["users"]
    end

    it 'should create board with a backlog but not transfer all properties' do
      created_board = TestProductBacklog.find_or_create_board({}, @backlog)
      created_board["_id"].should == nil
      created_board["_rev"].should == nil
      created_board["stories"].should == nil
      created_board["boards"].should == nil
    end
  end

  describe 'when it transfer_elements' do
    it 'should move elements from source to destination' do
      board = {}
      stories = @backlog["stories"].dup
      TestProductBacklog.transfer_elements!(@backlog, @backlog["stories"], board)
      board["stories"].should == stories
      @backlog["stories"].empty?.should == true
    end
  end

  describe 'when it replace_element' do
    it 'should replace the element in the array' do
      TestProductBacklog.replace_element(['a'], 'a', 'b').should == ['b']
      TestProductBacklog.replace_element([1, 2, 'a'], 'a', 'b').should == [1, 2, 'b']
    end

    it 'should do nothing if its not found' do
      TestProductBacklog.replace_element([], 'a', 'b').should == []
      TestProductBacklog.replace_element(['q'], 'a', 'b').should == ['q']
    end
  end

  describe 'when it update_previous_backlog' do
    it 'should update HEAD-1 with old board_id' do
      # add board
      head_board_id, previous_backlog_no_boards_id, previous_backlog_one_board_id,
        previous_board_id = TestProductBacklog.get_uuids(4)
      @backlog["boards"] << head_board_id

      # save, naming the copy - 0 boards on copy
      TestProductBacklog.update_board(@backlog, :copy_id => previous_backlog_no_boards_id)
      previous_backlog_no_boards = TestProductBacklog.get_board(previous_backlog_no_boards_id)
      head_backlog = TestProductBacklog.get_board(@backlog["_id"])

      previous_backlog_no_boards["boards"].length.should == 0
      head_backlog["boards"].first.should == head_board_id

      # save again, naming the copy - 1 board on copy
      TestProductBacklog.update_board(@backlog, :copy_id => previous_backlog_one_board_id)
      previous_backlog_one_board = TestProductBacklog.get_board(previous_backlog_one_board_id)
      head_backlog = TestProductBacklog.get_board(@backlog["_id"])
      head_backlog["boards"].first.should == head_board_id
      previous_backlog_one_board["boards"].first.should == head_board_id

      # replace the copy with  other id
      TestProductBacklog.update_previous_backlog(previous_backlog_one_board_id, head_board_id, previous_board_id)
      previous_backlog_one_board = TestProductBacklog.get_board(previous_backlog_one_board_id)
      previous_backlog_one_board["boards"].include?(previous_board_id).should == true

      # HEAD should remain - ie. have same board as at the start
      head_backlog = TestProductBacklog.get_board(@backlog["_id"])
      head_backlog["boards"].include?(head_board_id).should == true
    end
  end

  describe 'when it update_or_create_board' do
    before do
      @board = FactoryBoy.create(Fixture.board(0))
      @backlog["boards"] = [@board["_id"]]
      TestProductBacklog.update_board(@backlog, :no_copy => true)
    end

    it 'should keep things in sync when moving stories' do
      stories = @backlog["stories"].dup
      previous_board_id, previous_backlog_id = TestProductBacklog.update_or_create_board(@backlog, @board, @backlog["stories"])

      head_backlog = TestProductBacklog.get_board(@backlog["_id"])
      previous_backlog = TestProductBacklog.get_board(previous_backlog_id)

      head_backlog["boards"].first.should == @board["_id"]
      previous_backlog["boards"].first.should == previous_board_id
      head_backlog["stories"].length.should == 0
      previous_backlog["stories"].should == stories
    end

    it 'should add a new board' do
      @backlog["boards"] = []
      TestProductBacklog.update_board(@backlog, :no_copy => true)

      previous_board_id, previous_backlog_id = TestProductBacklog.update_or_create_board(@backlog)
      
      head_backlog = TestProductBacklog.get_board(@backlog["_id"])
      head_backlog["boards"].length.should == 1

      previous_backlog = TestProductBacklog.get_board(previous_backlog_id)
      previous_backlog["boards"].length.should == 0
    end

    it 'should add a new board with stories' do
      @backlog["boards"] = []
      TestProductBacklog.update_board(@backlog, :no_copy => true)

      stories = @backlog["stories"].dup
      board = {}

      previous_board_id, previous_backlog_id = TestProductBacklog.update_or_create_board(@backlog,board,stories)

      head_backlog = TestProductBacklog.get_board(@backlog["_id"])
      head_backlog["boards"].length.should == 1
      head_backlog["stories"].length.should == 0

      head_board = TestProductBacklog.get_board(head_backlog["boards"].first)
      stories.map! { |story|
        story.merge({"board_id" => head_board.id, "parent_id" => head_board.id})
      }
      head_board["stories"].should == stories

      previous_backlog = TestProductBacklog.get_board(previous_backlog_id)
      previous_backlog["stories"].length.should == stories.length

    end

    it "should update the board_id and parent_id of stories that are moved" do
      @backlog["boards"] = []
      TestProductBacklog.update_board(@backlog, :no_copy => true)

      stories = @backlog["stories"].dup
      board = {}

      previous_board_id, previous_backlog_id, board = TestProductBacklog.update_or_create_board(@backlog,board,stories)

      board.stories.map(&:board_id).uniq.should == [board.id]
      board.stories.map(&:parent_id).uniq.should == [board.id]
    end

  end
end
