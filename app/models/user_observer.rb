class UserObserver < ActiveRecord::Observer
  
  def before_create(user)
    user.make_activation_code
  end

  def after_create(user)
    # Notifier.deliver_signup_notification(user) if user.invited_code.blank?
  end

  def before_save(user)
    user.encrypt_password
  end

  def after_save(user)
    # Notifier.deliver_forgot_password(user) if user.recently_forgot_password?
    # Notifier.deliver_reset_password(user) if user.recently_reset_password?
  end  
end