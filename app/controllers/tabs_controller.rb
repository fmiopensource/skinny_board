class TabsController < ApplicationController
  def destroy
    respond_to do |format|
      format.js {
        boards_view_delete(params[:id].to_i)
        render :update do |page|
          page.remove "container_tab_board_#{params[:id]}"
          page.redirect_to :controller => 'boards', :action => 'index' unless
            request.env['HTTP_REFERER'].scan("boards/#{params[:id]}").empty? and
            request.env['HTTP_REFERER'].scan("product_backlogs/#{params[:id]}").empty?
        end
      }
    end
  end
end