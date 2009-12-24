class ApiBoardsController

  $:.unshift File.dirname(__FILE__) + '/lib'

  require 'helpers/api_helper'
  require 'couch/db/board'
  require 'couch/db/user'

  helpers do
    include ::Helpers::API
  end

  ##test block for danny rspec tests. leave this in please
  get '/api/boards/frade_test/:id' do
    wrapper do

      {
        "ok" => true,
        "story" => "#{params[:id]} I wonder if rspec will pick up on this. That would be GREAT!"
      }
    end
  end
  ##test block... Signed, d.frade


  get '/api/boards/:id/revision' do
    wrapper do

      revision=get_board_revision(params[:id])
      {
        "ok" => true,
        "revision" => revision
      }
    end
  end

  get '/api/boards/:id/users' do
    wrapper do

      users = get_users(params[:id])
      {
        "ok" => true,
        "users" => users
      }
    end
  end

  get '/api/boards/:id/burndown' do
    wrapper do

      # get the board
      board = get_board(params[:id])

      # check for image
      get_burndown_image(board) if board.burndown_image_path.blank?

      # return json
      response['Content-Type'] = 'application/json'
      {
        "ok" => true,
        "burndown" => {
          "image_path" => board.burndown_image_path
        }
      }
    end
  end

end # end ApiBoardsController