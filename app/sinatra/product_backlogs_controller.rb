class SinatraBoardsController

  $:.unshift File.dirname(__FILE__) + '/lib'

  require 'helpers/controller_helper'
  require 'couch/db/board'

  helpers do
    include ::Helpers::Controller
  end
  
  get '/product_backlog/:id' do
    @board = get_board(params[:id], :with_history => true)
    @sprints = get_docs(@board.boards)
    @sprints ||= []
    boards_viewed_add(params[:id], @board['title'][0..20])

    erb :"product_backlogs/show", :layout => :backlog_layout
  end

end
