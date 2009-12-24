class ApiStoriesController

  $:.unshift File.dirname(__FILE__) + '/lib'

  require 'helpers/api_helper'
  require 'couch/db/board'
  require 'couch/db/story'

  helpers do
    include ::Helpers::API
  end

  get '/api/boards/:id/stories/:story_id' do
    wrapper do
      story = get_story(params[:id], params[:story_id])
      if story.nil?
        status 404
        {"ok" => false, "error" => "Story not found."}
      else
        {"story" => story}
      end
    end
  end

  post '/api/boards/:id/stories' do
    cud_wrapper(get_board(params[:id])) do |board|

      # get board
      # board = get_board(params[:id])

      # create story
      story = create_story(board, params[:element])

      # update the board
      board["stories"] ||= []
      board.stories << story
    
      update_board(board, :add_up_stories => true)

      update_twitter(story, "created", board)

      # return json
      status 201
      result = {
        "ok" => true,
        "story" => story,
        "board" => {
          "story_points" => board.story_points,
          "rev" => board._rev
        }
      }
      if board.level==3
        result["updated_backlog"] = {:id => board.id,
          :badge => partial(:"boards/_board", :locals => {:board => board, :show_page => false}),
          :value => partial(:"product_backlogs/sortable_stories", :locals => {:board => board, :bulk => true})
        }
      end
      result
    end
  end

  put '/api/boards/:id/stories/:story_id' do
    cud_wrapper(get_board(params[:id])) do |board|

      # update story
      story = update_story(board, params[:story_id], params)

      # update board
      board.stories[story.position - 1] = story
      update_board(board, :reindex => true, :add_up_stories => true)

      # return json
      status 200
      {
        "ok" => true,
        "story" => story,
        "board" => {
          "story_points" => board.story_points,
          "rev" => board._rev,
          "level" => board.level
        }
      }
    end
  end

  delete '/api/boards/:id/stories/:story_id' do
    cud_wrapper(get_board(params[:id])) do |board|

      # delete story
      board.stories.delete_if { |s| s.id == params[:story_id] }

      # update board
      update_board(board, :reindex => true, :add_up_stories => true, :add_up_tasks => true)

      # return json
      {
        "ok" => true,
        "board" => {
          "hours" => board.hours,
          "story_points" => board.story_points,
          "rev" => board._rev
        }
      }
    end
  end

end
