class UserSessionController < ApplicationController
  before_filter :login_required
  skip_before_filter :verify_authenticity_token

  def delete
    respond_to do |format|
      format.js {
        boards_view_delete(params[:id])
        render :update do |page|
          page.remove "tab_board_#{params[:id]}"
        end
      }
    end
  end
end