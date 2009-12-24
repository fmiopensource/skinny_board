class SinatraTextImporterController

  $:.unshift File.dirname(__FILE__) + '/lib'

  require 'helpers/controller_helper'
  require 'couch/db/board'
  require 'couch/db/story'
  require 'couch/db/user'
  require 'couch/db/task'

  helpers do
    include ::Helpers::Controller
  end
  
  get "/text_importer/new" do
    login_required
    authorization_required(params[:id])
    
    @board = get_board(params[:id])
    erb :"text_importer/new"
  end
  
  post "/text_importer" do
    login_required
    authorization_required(params[:id])

    board = get_board(params[:id])
    board["stories"] ||= []
    story_text = params[:stories].split("\n")
    position = board.stories.empty? ? 1 : board.stories.length + 1
    
    story_text.each do |desc|
      unless desc.blank?
        story = create_story(board, {"story_points" => "0.0", "title" => "Story #{position}", "description" => desc, "creator_id" => current_user})
        board.stories << story
        position += 1
      end
    end
    
    update_board(board, :add_up_stories => true)
    
    redirect "/boards/#{board._id}"
  end
end