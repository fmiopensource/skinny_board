# Be sure to restart your server when you modify this file

#require 'spec/rails'
# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.3' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
require 'RedCloth'
require 'lib/array.rb'
require 'lib/string.rb'
require 'lib/nil.rb'

Rails::Initializer.run do |config|
  config.gem 'mislav-will_paginate', :version => '~> 2.3.6', :lib => 'will_paginate', :source => 'http://gems.github.com'
  config.gem "calendar_date_select"
  config.gem "RedCloth"
  config.gem 'ezcrypto'
  config.gem 'twitter4r', :version => "~> 0.3.0", :lib => "twitter"
  config.gem 'aws-s3', :version => "~> 0.6.2", :lib => 'aws/s3'
  config.gem 'ruby-recaptcha'
  config.gem 'sinatra'
  config.gem 'eee-c-couch_design_docs', :lib => 'couch_design_docs', :version => "1.0.2"
  config.gem 'thin'
  config.active_record.observers = :user_observer
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Specify gems that this application depends on. 
  # They can then be installed with "rake gems:install" on new installations.
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Comment line to use default local time.
  config.time_zone = 'UTC'

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_skinny_board_v1_5_session',
    :secret      => 'aba79c7d443291554659101251857984bfa4c5e2c4a8604587ace892f8dc194b07e808760dd69afb268283f852909d434d90181de1b5d7d0e239e2453f876e44'
  }
  
  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector


  #FMI STUFF
  STATUS_TODO = 1
  STATUS_IN_PROCESS = 2
  STATUS_TO_VERIFY = 3
  STATUS_DONE = 4
  STATUS_COMPLETE = 5
  STATUS_ACTIVE = 6
  STATUS_INACTIVE = 7
  STATUS_PARKED = 8
  STATUS_DELETED = 9
  STATUS_DEMO = 10

  STATUS_CODES = ["Story", "Tasks", "In Process", "To Verify", "Done"]


  COMPANY_STATUS_ACTIVE = 1
  COMPANY_STATUS_CANCELED = 2
  COMPANY_STATUS_SUSPENDED = 3

  BOARD_STATII = [STATUS_TODO, STATUS_IN_PROCESS, STATUS_TO_VERIFY, STATUS_DONE]

  LEVEL_BOARD = 0
  LEVEL_STORY = 1
  LEVEL_TASK = 2
  LEVEL_PRODUCT_BACKLOG = 3

  VALID_STORY_POINTS =  %w~* 0.0 0.5 1.0 2.0 3.0 5.0 8.0 13.0 20.0 40.0 100.0 ?~

  DEFAULT_AVATAR = '/images/default_avatar.gif'
  MULTI_AVATAR = '/images/multi_user_avatar.gif'

  BURNDOWN_NO_IMAGE = "/images/Burndown_No_Data.gif"

  #TODO: REMOVE ME LATER!
  AMAZON_ACCESS_KEY_ID='your access key here'
  AMAZON_SECRET_ACCESS_KEY='your secret access key'
  AMAZON_BUCKET='your bucket'

  #these must be lower cased, used to determine if a card should be red
  ERROR_TAGS = ['error', 'bug', 'bugs']

  #these must be lower cased, used to determine if a card should be
  #cucumber green (or whatever format, cucumber items are
  CUCUMBER_TAGS = ['cucumber']

  REORDER_STORIES_PER_COLUMN = 6
end

set :views, "#{RAILS_ROOT}/app/sinatra/views"
set :run, false

# Remove trailing slash from URIs reaching Sinatra
before { request.env['PATH_INFO'].gsub!(/\/$/, '') if request.env['PATH_INFO'] != '/' }

require 'sinatra/application_controller'
require 'sinatra/boards_controller'
require 'sinatra/users_controller'
require 'sinatra/product_backlogs_controller'
require 'sinatra/api_boards_controller'
require 'sinatra/api_stories_controller'
require 'sinatra/api_tasks_controller'
require 'sinatra/api_product_backlogs_controller'
require 'sinatra/text_importer_controller'
require 'sinatra/priorities_controller'