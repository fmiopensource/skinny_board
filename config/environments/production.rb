# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true
config.action_controller.session.merge!(:session_domain => 'your domain')
# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host                  = "http://assets.example.com"

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

GOOGLE_ANAL = true
# Recaptcha
RECAPTCHA = false
RCC_PUB = 'your public recaptcha key' 
RCC_PRIV = 'your private recaptcha key'

EMAIL_FROM_ADDRESS = "your email address"
ActionMailer::Base.smtp_settings = {
  :address => "your address",
  :port => 25,
  :domain => 'your domain',
  :user_name => 'username',
  :password => 'password',
  :authentication => :login
}

SITE_ADDRESS_FOR_EMAIL = 'skinnyboard.com'

# Uncomment for redirecting from skinnyboard.com to subdomain.skinnyboard.com
ActionController::Base.session_options[:session_domain] = 'skinnyboard.com'
COUCHDB_BLANK = "stage"
COUCHDB_HOST = 'http://localhost:5984'