class InvitesController < ApplicationController
  
  before_filter :login_required, :only => ['new', 'create' ]
  
  # GET /users
  def new 
    @user = User.new
  end
    
  # POST /users  
  def create
    @user = User.new(params[:user])
    @user.email.strip!

    #Force a call to validation
    @user.valid?
    if @user.errors.on(:email).nil?
      
      @user.generate_invite_code
      @user.company_id = current_user.company_id
      @user.save(false)
      
      flash[:notice] = "The user has received an email and can now sign up"
      Notifier.deliver_invite_user(@user)
      redirect_to :controller => '/invites', :action => 'new'
    else
      render :action => 'new'
    end
  end
  
  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        unless @user.invited_code.blank?
          self.current_user = User.authenticate(@user.login,
            @user.password, @user.company_id)
        end
        
        @user.invited_code = ''
        @user.activated_at = DateTime.now
        @user.save!
        @user.upload_avatar(params[:user_avatar], params[:remove_image] == 'checked')
        flash[:notice] = 'Account Created. Welcome to SkinnyBoard'
        format.html { redirect_to(user_path(@user)) }
        format.xml  { head :ok }
      else
        format.html { render :template => "users/new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end  
  
end
