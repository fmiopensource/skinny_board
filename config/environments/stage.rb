# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false
config.action_controller.session.merge!(:session_domain => 'skinnyboard.net')
# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false

# turn on google analytics?
GOOGLE_ANAL = true

# action mail order bride
config.action_mailer.raise_delivery_errors = false

EMAIL_FROM_ADDRESS = "your email address"
ActionMailer::Base.smtp_settings = {
  :address => "your address",
  :port => 25,
  :domain => 'your domain',
  :user_name => 'username',
  :password => 'password',
  :authentication => :login
}

SITE_ADDRESS_FOR_EMAIL = 'skinnyboard.net'

# Recaptcha
RECAPTCHA = false
RCC_PUB = 'your public recaptcha key' 
RCC_PRIV = 'your private recaptcha key'

ActionController::Base.session_options[:session_domain] = 'skinnyboard.net'
COUCHDB_BLANK = "stage"
COUCHDB_HOST = 'http://localhost:5984'