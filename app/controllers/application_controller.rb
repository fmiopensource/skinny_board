class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  
  include AuthenticatedSystem
  include ReCaptcha::AppHelper if RECAPTCHA
  include UserSession

  before_filter :set_url_for_mailer
  before_filter :login_from_cookie, :except => ['hours']
  before_filter { |c| User.current_user = c.current_user}
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'ed234dac3ff4f7d946a751b9fe992215'
  
  def set_url_for_mailer
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end
  
  def check_user_permissions
    company = Company.find(current_user.company_id)
    if !(company.owner_id == current_user.id or current_user.id != params[:id] )
      flash[:error] = "You do not have permission to access this user account"
      redirect_to "/boards"            
    end
  end

  def check_company_permissions
    company = Company.find(current_user.company_id)
    if (company.owner_id != current_user.id)
      flash[:error] = "You do not have permission to access this company account"
      redirect_to "/boards"
    end
  end
end
