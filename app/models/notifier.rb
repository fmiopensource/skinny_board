class Notifier < ActionMailer::Base
  
  def user_assignment(user_ids, task_description, board_id, current_user)
    return if user_ids.blank?
    setup_email_boilerplate
    domain = User.find(user_ids.first).subdomain.downcase
    @recipients  = User.find(user_ids).collect{|u| u.email}.join(',')
    @subject += "An item has been assigned to you"
    @body[:url] = "http://#{domain}.#{SITE_ADDRESS_FOR_EMAIL}/boards/#{board_id}"
    @body[:task_description] = task_description
    @body[:assigning_user] = User.find(current_user).full_name
  end

  def invite_user( user )
    setup_email(user)
    subject "You have been invited to skinnyboard.com"
    body :user=> user
  end  
  
  def beta_request (user)
    setup_email(user)
    @subject += "Beta Request"
    @recipients  = BETA_REQUEST_RECIPIENTS
  end

  def forgot_password(user)
    setup_email(user)
    @subject    += 'Request to change your password'
    @body[:url]  = "http://#{user.subdomain.downcase}.#{SITE_ADDRESS_FOR_EMAIL}/account/reset_password?reset_code=#{user.password_reset_code}"
  end

  def reset_password(user)
    setup_email(user)
    @subject    += 'Your password has been reset'
  end
  
  def signup_notification(user)
    setup_email(user)
    @subject += "Your account has been created"
    @body[:subdomain] = user.subdomain
    @body[:url] = "#{SITE_ADDRESS_FOR_EMAIL}/account/activate/#{user.activation_code}"
  end
  
  def activation(user)
    setup_email(user)
    @subject += "Your account has been activated"
  end

protected
  def setup_email(user)
    setup_email_boilerplate
    @recipients  = "#{user.email}"
    @body[:user] = user
  end
  def setup_email_boilerplate
    @from        = EMAIL_FROM_ADDRESS
    @subject     = "SkinnyBoard.com "
    @sent_on     = Time.now
  end
end