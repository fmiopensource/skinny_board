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

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false
config.action_controller.session.merge!(:session_domain => 'skinnyboard.local')

# turn on google analytics?
GOOGLE_ANAL = false

# action mail order bride
config.action_mailer.raise_delivery_errors = true


EMAIL_FROM_ADDRESS = "your email address"
ActionMailer::Base.smtp_settings = {
  :address => "your address",
  :port => 25,
  :domain => 'your domain',
  :user_name => 'username',
  :password => 'password',
  :authentication => :login
}

SITE_ADDRESS_FOR_EMAIL = 'skinnyboard.local:3000'

# IMPORTANT: Must add skinnyboard.local to /etc/hosts file as 'localhost' is not allowed
# Then use http://skinnyboard.local:3000 to test the site in dev
ActionController::Base.session_options[:session_domain] = 'skinnyboard.local'

# Recaptcha
RECAPTCHA = false
RCC_PUB = 'your public recaptcha key' 
RCC_PRIV = 'your private recaptcha key'

COUCHDB_BLANK = "stage"
COUCHDB_HOST = 'http://localhost:5984'
SB_BASE_URL = 'http://stage.skinnyboard.local:3000'