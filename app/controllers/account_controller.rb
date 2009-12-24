class AccountController < ApplicationController  
  def login
    return unless request.post?
    company = Company.find_by_subdomain(current_subdomain)
    unless company.nil?
      self.current_user = User.authenticate(params[:login], params[:password], company.nil? ? 0 : company.id)
      if logged_in?
        remember_user if params[:remember_me] == "1"
        
        # put some things into the session for sinatra
        boards_viewed
        session[:subdomain] = self.current_user.subdomain
        session[:company_id] = self.current_user.company.id

        flash[:notice] = "Logged in successfully"
        redirect_back_or_default('/boards')
      else
        flash[:notice] = "Unable to validate your login credentials.  Please check your email and ensure your account has been activated"
      end
    else
      flash[:notice] = "You must log in from your subdomain."
    end
  end
  
  def logout
    forget_user
    flash[:notice] ||= "You have been logged out."
    redirect_back_or_default("/")
  end
    
  def activate 
    @user = params[:id].blank? ? nil : User.find_by_activation_code(params[:id])
    if @user and @user.activate 
      self.current_user = @user 
      redirect_back_or_default("/boards") 
      flash[:notice] = "Your account has been activated."
    else
      flash[:notice] = "We were unable to activate your account"
      redirect_to(:controller => 'account', :action => 'login')
    end
  end
  
  def forgot_password
    return unless request.post?
    company = Company.find_by_subdomain(current_subdomain)
    unless company.nil?
      @user = User.find_by_email_and_company_id(params[:email], company.id)
      unless @user.nil?
        @user.forgot_password and @user.save
        flash[:notice] = "A password reset link has been sent to your email address" 
        redirect_back_or_default(:controller => '/account', :action => 'login')
      else
        flash[:notice] = "Could not find a user with that email address" 
      end
    else
      flash[:notice] = "Password reset link must be accessed from your subdomain"
    end
  end
  
  def reset_password
    company = Company.find_by_subdomain(current_subdomain)
    unless company.nil?
      begin
        @user = User.find_by_password_reset_code(params[:reset_code])
        raise if @user.nil?
        return unless request.post?
        
        if @user.reset_password(params[:password], params[:password_confirmation])
          flash[:notice] = "Password has been reset."
          redirect_to "/login"
        end
      rescue
        logger.error "Invalid Reset Code entered" 
        flash[:notice] = "Sorry - That is an invalid password reset code. Please check your code and try again. (Perhaps your email client inserted a carriage return?" 
        redirect_back_or_default("/login")
      end
    else
      flash[:notice] = "You must reset your password from your subdomain."
    end
  end
end

