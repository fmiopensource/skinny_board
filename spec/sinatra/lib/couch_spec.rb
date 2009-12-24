require File.dirname(__FILE__) + '/../../spec_helper'
require "#{RAILS_ROOT}/app/sinatra/lib/couch/couch"
require "#{RAILS_ROOT}/app/sinatra/lib/couch/db/board"
require "#{RAILS_ROOT}/app/sinatra/lib/couch/db/story"
require "#{RAILS_ROOT}/app/sinatra/lib/couch/db/task"
require "#{RAILS_ROOT}/app/sinatra/lib/couch/db/user"

require "#{RAILS_ROOT}/spec/sinatra/fixtures/fixture"

class TestCouch
  extend Couch::DB
end

describe TestCouch do
  before do
    TestCouch.stub!(:current_company).and_return(COUCHDB_TEST_DB[1..-1])
    TestCouch.stub!(:current_user).and_return(1) #must be set to a value in the document
  end
  
  it 'should know the server' do
    TestCouch.server.should == "#{COUCHDB_HOST}/#{COUCHDB_TEST_DB}"
  end

  describe "getting data when there are no board" do
    before(:all) do
      RestClient.delete "#{COUCHDB_HOST}/#{COUCHDB_TEST_DB}", { }
      RestClient.put("#{COUCHDB_HOST}/#{COUCHDB_TEST_DB}", {}.to_json).to_s # get rid of this when using couch 0.10
      RestClient.post("#{COUCHDB_HOST}/_replicate", {
        "source" => COUCHDB_BLANK,
        "target" => COUCHDB_TEST_DB,
        "create_target" => "true"}.to_json).to_s
    end
    it 'should not find any boards' do
      TestCouch.get_boards.should == []
    end
    it 'should not find a board' do
      TestCouch.get_board('no_boards').should == nil
    end
    it 'should not get_board_history' do
      TestCouch.get_board_history('there_is_none').should == []
    end
    it 'should not get_board' do
      TestCouch.get_board('there_is_none').should == nil
    end
    it 'should get_board_revision' do
      TestCouch.get_board_revision('there_is_none').should == []
    end
    it 'should not get_burndown_points' do
      TestCouch.get_burndown_points('there_is_none', '11/11/11').should == []
    end
    it 'should not get_doc when there are none' do
      TestCouch.get_doc('there_is_none').should == nil
    end
  end

  describe "getting data when there are no stories" do
    before do
      @board = FactoryBoy.create(Fixture.board(0, :no_stories => true))
    end

    it 'should not get_story' do
      TestCouch.get_story(@board["_id"], "there_is_no_spoon").should == nil
    end

    it 'should not get_stories' do
      TestCouch.get_stories(@board["_id"]).should == {}
    end

    it 'should not get_task without stories' do
      TestCouch.get_task(@board["_id"], "there_are_none", "there_are_none").should == nil
    end
    it 'should not get_burndown_points' do
      TestCouch.get_burndown_points(@board["_id"], @board["updated_at"]).should == []
    end
  end

  describe "getting data when there are no tasks" do
    before do
      @board = FactoryBoy.create(Fixture.board(0, :no_tasks => true))
    end
    it 'should not get_task without tasks' do
      TestCouch.get_task(@board["_id"], @board["stories"].first["id"], 'there_are_none').should == nil
    end
    it 'should not get_burndown_points' do
      TestCouch.get_burndown_points(@board['_id'], @board["updated_at"]).should == []
    end
  end

  describe "getting data when there are no users" do
    it 'should not get_users' do
      board = FactoryBoy.create(Fixture.board(0, :no_users => true))
      TestCouch.get_users(board["_id"]).should == []
    end
  end  

describe "getting data" do
  before do
    @board = FactoryBoy.create(Fixture.board)
    @board2 = FactoryBoy.create(Fixture.board)
  end

  it 'should get_story' do
    story_no_tasks = @board["stories"].first
    story_no_tasks["tasks"] = []
    TestCouch.get_story(@board["_id"], @board["stories"].first["id"]).should == story_no_tasks
  end

  it 'should get_stories' do
    stories_hash = {}
    @board["stories"].collect{|story|
      stories_hash[story.id]=story}
    TestCouch.get_stories(@board["_id"]).should == stories_hash
  end

  it 'should get_task' do
    TestCouch.get_task(@board["_id"], @board["stories"].first["id"],
      @board["stories"].first["tasks"].first["id"]).should == @board["stories"].first["tasks"].first
  end

  it 'should get_users' do
    TestCouch.get_users(@board["_id"]).should == (@board["users"])
  end

  it 'should get_boards' do
    board2 = FactoryBoy.create(Fixture.board(0, :no_stories => true))
    board_array = TestCouch.get_boards.collect{|board| board["value"]}
    board_array.should include(@board["value"])
    board_array.should include(board2["value"])
  end

  it 'should get_board' do
    TestCouch.get_board(@board["_id"]).should == @board
  end

  it 'should get_board_history' do
    FactoryBoy.create(Fixture.board, @board["_id"])
    rows = TestCouch.get_board_history(@board["_id"])
    rows.length.should == 2
    rows.first["key"].first.should == @board["_id"]
    rows.last["key"].first.should == @board["_id"]
  end

  it 'should get_board_revision' do
    TestCouch.get_board_revision(@board["_id"]).should == @board["_rev"]
  end

  it 'should get_burndown_points' do
    updated_at = @board["updated_at"]
    date = Date.parse(updated_at)
    board_id = @board["_id"]
    task_hours = (@board["stories"].map {|story| story["tasks"].first["hours"]}).total
    date_last = date - 26.hours
    date_first = date - 27.hours

    run_the_numbers = ->(index, year, month, day, hours){
      rows = TestCouch.get_burndown_points(board_id, updated_at)
      rows[index]["key"].should == ["#{board_id}", year, month - 1, day]
      rows[index]["value"]["hours"].should == hours
      return rows.count
    }

    # only 1 point for @board
    count = run_the_numbers.call(0, date.year, date.month, date.day, task_hours)
    count.should == 1

    # add another, 2 points: @board and this
    child = Fixture.board
    child["stories"].first.tasks.first["hours"] = 33
    child["updated_at"] = date_first.strftime("%Y/%m/%d %H:%M:%S %z")
    FactoryBoy.create(child, board_id)

    run_the_numbers.call(0, date_first.year, date_first.month, date_first.day, 43)
    count = run_the_numbers.call(1, date.year, date.month, date.day, task_hours)
    count.should == 2

    # add another, still 2 points, @board and this, not 33
    child = Fixture.board
    child["stories"].first.tasks.first["hours"] = 99
    child["updated_at"] = date_last.strftime("%Y/%m/%d %H:%M:%S %z")
    FactoryBoy.create(child, board_id)
    
    run_the_numbers.call(0, date_last.year, date_last.month, date_last.day, 109)
    count = run_the_numbers.call(1, date.year, date.month, date.day, task_hours)
    count.should == 2
  end

  it 'should get_doc' do
    TestCouch.get_doc(@board["_id"]).should == @board
  end

  it "should get a list of documents" do
    documents=TestCouch.get_docs([@board["_id"],@board2["_id"]])

    documents.length.should==2
    documents.map{ |d| d["_id"]}.should include(@board["_id"], @board2["_id"])
  end

  it 'should board_user_authorized? with just the board_id' do
    TestCouch.board_user_authorized?(@board["_id"]).should == true
  end

  it 'should board_user_authorized? with board id and brians ID' do
    TestCouch.board_user_authorized?(@board["_id"],3).should == true
  end

  it 'should not board_user_authorized? with board id and invalid user id' do
    TestCouch.board_user_authorized?(@board["_id"],43728943728347432437).should == false
  end
end

it 'should get_uuids' do
  uuid_array = TestCouch.get_uuids
  uuid_array.length.should be > 0
end

  describe 'save board' do
    before do
      @board = {}
      @rev = TestCouch.save_board(@board, :no_copy => true)[0]
    end

    it 'should retrieve the saved doc' do
      board = TestCouch.get_doc(@board["_id"])
      board.should_not == nil
      board["_id"].should == @board["_id"]
    end

    it 'should retrieve the head doc after copy/save' do
      TestCouch.save_board(@board)
      board = TestCouch.get_doc(@board["_id"])
      board.should_not == nil
      board["_id"].should == @board["_id"]
    end

    it 'should copy_doc' do
      keys = TestCouch.copy_doc(@board, TestCouch.get_uuids.first).keys
      keys.include?("_id").should == true
      keys.include?("rev").should == true
    end
  
    it 'should save_doc' do
      @board["_rev"] = @rev
      rev, success = TestCouch.save_doc(@board)
      success.should == true
      rev.to_i.should == 2
    end
  end
end
