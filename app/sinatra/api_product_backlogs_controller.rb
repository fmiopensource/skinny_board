class ApiProductBacklogsController

  $:.unshift File.dirname(__FILE__) + '/lib'

  require 'helpers/api_helper'
  require 'couch/db/board'
  require 'couch/db/story'
  require 'couch/db/user'
  require 'couch/db/task'

  helpers do
    include ::Helpers::API
  end
  
  post '/api/product_backlogs/:id/board' do
    cud_wrapper(get_board(params[:id], :with_history => false)) do |backlog|
 
      stories = params[:stories].nil? ? [] : backlog.stories.select {|story| params[:stories].include? story.id }
      board_copy_id, backlog_copy_id, board = update_or_create_board(backlog, {"title" => params[:title], "description" => ""}, stories)

      reorder_stories(backlog) and reorder_stories(board)
      save_board(backlog) and save_board(board)

      response['Content-Type'] = 'application/json'
      {
        "ok" => true,
        "new_board" => { :id => board.id, :title => board.title,
          :value => partial(:"product_backlogs/sprint", :locals => {:board => board, :bulk => false})},
        "stories" => params[:stories],
        "updated_backlog" => {:id => backlog.id,
          :value => partial(:"product_backlogs/sortable_stories", :locals => {:board => backlog,
              :bulk => true})}
      }
    end
  end

  put '/api/product_backlogs/:id/board' do
    cud_wrapper(get_board(params[:id], :with_history => false)) do |backlog|
      stories = backlog.stories.select {|story| params[:stories].include? story.id }
      sprint = get_board params[:sprint_id], :with_history => false

      board_copy_id, backlog_copy_id, sprint = update_or_create_board(backlog, sprint, stories)

      reorder_stories(backlog) and reorder_stories(sprint)
      save_board(backlog) and save_board(sprint)

      response['Content-Type'] = 'application/json'
      {
        "ok" => true,
        "updated_board" => { :id => sprint.id, :title => sprint.title,
          :value => partial(:"product_backlogs/sprint", :locals => {:board => sprint,
              :bulk => false})},
        "stories" => params[:stories],
        "updated_backlog" => {:id => backlog.id,
          :badge => partial(:"boards/_board", :locals => {:board => backlog, :show_page => false}),
          :value => partial(:"product_backlogs/sortable_stories", :locals => {:board => backlog,
              :bulk => true})}
      }
    end
  end

  delete '/api/product_backlogs/:id/story' do
    cud_wrapper(get_board(params[:id], :with_history => false)) do |backlog|
      original_story_count=backlog["stories"].length
      backlog["stories"].delete_if {|s| params[:stories].include? s.id}

      backlog_copy_id = get_uuids(1)
      update_board(backlog, {:copy_id => backlog_copy_id, :add_up_stories => true})
      success=backlog["stories"].length==(original_story_count - params[:stories].length)
      response['Content-Type'] = 'application/json'
      {
        "ok" => success,
        "updated_backlog" => {
          :id => backlog.id,
          :value => partial(:"product_backlogs/sortable_stories", :locals => {:board => backlog, :bulk => true}),
          :badge => partial(:"boards/_board", :locals => {:board => backlog, :show_page => false})
        },
        "stories" => params[:stories]
      }
    end
  end

end
