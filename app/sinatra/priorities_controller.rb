class SinatraPrioritiesController
    $:.unshift File.dirname(__FILE__) + '/lib'

  require 'helpers/controller_helper'
  require 'couch/db/board'
  require 'couch/db/story'
  require 'couch/db/user'
  require 'couch/db/task'

  helpers do
    include ::Helpers::Controller
  end
  
  get '/boards/priorities/:id/edit' do
    login_required
    authorization_required(params[:id])
    @board = get_board(params[:id], :with_history => false)

    erb :"/priorities/edit", :layout => :layout_priority
  end

  post '/boards/priorities/:id/update' do
    login_required
    authorization_required(params[:id])
    @board = get_board(params[:id], :with_history => true)
    @stories = get_stories(@board.id)

    ordered_stories = []
    #params[:stories] is posted in the new order, so itterate through ordered array
    #and rebuild the story array for the board
    JSON.parse(params[:stories]).each_with_index do |story_id, index|
      ordered_stories << @stories[story_id].merge!({:position => index+1}) if @stories.has_key?(story_id)
    end

    @board["stories"] = ordered_stories
    update_board(@board, :add_up_stories => true)

    "OK"
  end

end
