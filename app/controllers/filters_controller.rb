require 'yaml'

class FiltersController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def create
    render :text => "PUBLIC" and return unless logged_in?
    user_id = current_user.id

    if params[:story_id]
      UserBoardFilter.add_story_filter(params[:story_id], user_id, params[:is_open], params[:board_id])
    elsif params[:status_id]
      UserBoardFilter.add_status_filter(params[:status_id], user_id, params[:board_id], params[:is_open])
    elsif params[:text_filter]
      UserBoardFilter.add_text_filter(params[:text_filter], user_id, params[:board_id])
    end
    render :json => "ok".to_json
  end
end