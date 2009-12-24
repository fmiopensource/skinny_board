class UsersController < ApplicationController
  before_filter :login_required, :only => ['index', 'show', 'edit', 'delete']
  before_filter :check_user_permissions, :only => ['index', 'show', 'edit', 'delete']
  
  # GET /users
  # GET /users.xml
  def index
    @users = User.paginate(:conditions => ["company_id = ?", current_user.company_id], :page => params[:page] || 1, :per_page => 15)
    @company = current_user.company
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @users}
      format.js
    end
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
  end

  # GET /users/new
  # GET /users/new.xml
  def new    
    if logged_in?
      current_user.forget_me if logged_in?
      self.current_user = nil
      cookies.delete :auth_token
      reset_session
    end
    
    flash[:notice] = ''

    @user = User.find(:first, :conditions => ["invited_code = ?", params["invited_code"]]) if params.has_key?("invited_code")
    @user ||= User.new
    
    @company = Company.new

    render :layout => 'html'
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
    @user.twitter_password =  crypto_key.decrypt64(@user.twitter_password) unless @user.twitter_password.blank?
  end

  # POST /users
  # POST /users.xml
  def create

    # we dont want the activation to fire here
    # so set an invite and then blank it
    params[:user][:invited_code] = 'creating company'
    twitter_pw = cryptify(params[:user][:twitter_password]) unless params[:user].blank?
    params[:user][:twitter_password] = twitter_pw unless twitter_pw.nil?
    @user = User.new(params[:user])
    # @company = Company.new(params[:company])
    @company = Company.new
    @user.invited_code = nil
    
    user_valid = @user.valid?
    
    if user_valid and (RECAPTCHA ? validate_recap(params, @user.errors) : true)
      @company.name = "#{@user.first_name}'s Company"
      @company.save(false)
      @company.update_attributes(:subdomain => "company#{@company.id}")
      
      @user.company ||= @company
      
      @user.save(false)
      @company.owner_id = @user.id
      @company.users << @user
      @company.company_status_id = COMPANY_STATUS_ACTIVE
      @company.save(false)
      @user.upload_avatar(params[:user_avatar])
      
      # don't activate for sign-up, only for invited users
      @user.activate
      self.current_user=@user
      
        redirect_to :controller => 'users', :action => 'index', :subdomain => @company.subdomain.downcase
      flash[:notice] = "Thanks for signing up!"
    else
      @company.errors.each{|attr, msg| @user.errors.add_to_base("#{attr.humanize} - #{msg}")} unless @company.errors.nil?
      render :action => 'new'
    end

  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    params[:user][:password] = nil if params[:user] and params[:user][:password] == ""
    twitter_pw = cryptify(params[:user][:twitter_password]) unless params[:user].blank?
    params[:user][:twitter_password] = twitter_pw unless twitter_pw.nil?
    respond_to do |format|
      if @user.update_attributes(params[:user])
        @user.invited_code = ''
        @user.save!
        @user.upload_avatar(params[:user_avatar], params[:remove_image] == 'checked')
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(users_url) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    flash[:notice] = 'User was deleted'
    redirect_to(users_url)
  end

private

  def cryptify(password_to_encrypt)
    crypto_key.encrypt64(password_to_encrypt) unless password_to_encrypt.blank?
  end

  def crypto_key
    EzCrypto::Key.with_password "password", "system salt"
  end
end
