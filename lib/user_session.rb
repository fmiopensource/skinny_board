module UserSession
  def boards_viewed
    session[:boards_viewed] ||= viewed_boards_from_filter || Array.new
    return session[:boards_viewed]
  end

  def boards_viewed_add(id, name, type=nil)
    unless boards_viewed.select{|b| b[:id] == id}.empty?
      boards_view_delete(id)
    end
    session[:boards_viewed].unshift({:id => id, :name => name, :type => type})
    session[:boards_viewed].pop if session[:boards_viewed].length > 15
    UserBoardFilter.update_viewed_boards(current_user, 0, session[:boards_viewed]) if logged_in?
    return session[:boards_viewed]
  end

  def boards_view_delete(id)
    unless id.nil?
      session[:boards_viewed].delete_if{|b| b[:id] == id}
      UserBoardFilter.update_viewed_boards(current_user, 0, session[:boards_viewed]) if logged_in?
      return session[:boards_viewed]
    end
  end
  
  def remember_user
    current_user.remember_me
    cookies[:auth_token] = { :value => current_user.remember_token , :expires => current_user.remember_token_expires_at }
  end
  
  def forget_user
    current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
  end

private
  def viewed_boards_from_filter
    if logged_in?
      filter = UserBoardFilter.find(:first, :conditions => {:board_id => 0, :user_id => current_user})
      return filter.viewed_boards unless filter.nil?
    end
  end
end