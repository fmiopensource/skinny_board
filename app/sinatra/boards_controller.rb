class SinatraBoardsController

  $:.unshift File.dirname(__FILE__) + '/lib'

  require 'helpers/controller_helper'
  require 'couch/db/board'
  require 'couch/db/user'

  helpers do
    include ::Helpers::Controller
  end
  
  get '/boards' do
    login_required
    @boards = get_boards.map{ |b| {"id" => b.id, "_id" => b.id}.merge(b.value) }.sort_by {
      |b| b.updated_at
    }.reverse
    @show_filters = true
    erb :"boards/index"
  end

  get '/boards/new' do
      @board = {"twitter" => {}, "level" => 0}
      erb :"boards/new"
  end

  get '/boards/:id' do
    @board = get_board(params[:id], :with_history => true)
    @can_edit = false
    @hidden_stories = @hidden_columns = @text_filter = nil

    unless @board.is_public
      login_required
      authorization_required(params[:id])
    end

    if logged_in?
      @can_edit = (@board.id == @board.parent_id) && authorized?(params[:id])
      @hidden_stories = get_hidden_stories(current_user, params[:id])
      @hidden_columns = get_hidden_columns(current_user, params[:id])
      @text_filter    = get_text_filter(current_user, params[:id]) || ''
      boards_viewed_add(params[:id], @board['title'][0..20])
    end
    
    if @board.level == LEVEL_BOARD
      erb :"boards/show", :layout => :layout_show
    elsif @board.level == LEVEL_PRODUCT_BACKLOG
      redirect "/product_backlog/#{@board.id}"
    end
  end

  # create that board
  post '/boards' do
    login_required
    
    @board = create_board(params[:element].merge({"twitter" => params[:twitter] || {}}))
    putsc "board: #{@board}"

    begin
      save_board(@board, :no_copy => true)
      update_board_twitter(@board, "created")
      flash[:notice] = 'Your board has been created. Rejoice!'
      redirect "/#{@board.level == LEVEL_BOARD ? 'boards' : 'product_backlog'}/#{@board.id}"

    rescue Exception => e
      flash[:error] = "#{e}"
      erb :"boards/new"

    end
  end

  # edit that board
  get '/boards/:id/edit' do
    login_required
    authorization_required(params[:id])
    
    @board = get_board params[:id], :with_history => false
    @owner, @available_users = get_board_users(@board)

    erb :"boards/edit"
  end

  # update that board
  post '/boards/:id' do
    login_required
    authorization_required(params[:id])

    board_id = params[:id]
    @boards = {}
    begin
      @board = get_board board_id, :with_history => false
      @board = board_edit(@board, params)
      update_board(@board)
      update_board_twitter(@board, "updates")
      redirect "/boards/#{board_id}"

    rescue Exception => e
      @owner, @available_users = get_board_users(@board)
      flash[:error] = "#{e}"
      erb :"boards/edit"

    end
  end

end # end SinatraBoardsController
