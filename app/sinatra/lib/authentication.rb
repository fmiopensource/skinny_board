module SkinnyBoard
  module Authentication
    # Returns true or false if the user is logged in.
    # Preloads @current_user with the user model if they're logged in.
    def logged_in?
      !(current_user.nil? || current_subdomain.nil?)
    end

    # Store the given user in the session.
    def current_user
      session[:user]
    end

    def current_subdomain
      #session[:subdomain]
      get_current_subdomain
    end

    def current_company
      #session[:company_id]
      get_current_company
    end

    def current_token
      session[:_csrf_token]
    end

    # redirect if we're not logged in
    def login_required
      redirect '/login', 303 unless logged_in?
    end

    def authorized?(board_id)
      board_user_authorized?(board_id)
    end

    def authorization_required(board_id)
      redirect('/boards', 303) unless authorized?(board_id)
    end
   
    # Since current company and subdomain are set on login, it won't be set
    # for public boards viewed not logged in users
    def get_current_company
      Company.find_by_subdomain(current_subdomain).id
    end
    def get_current_subdomain
      request.env["SERVER_NAME"].split('.')[0]
    end
  end # End Module Authentication
end # End Module SkinnyBoard