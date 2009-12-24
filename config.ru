require ::File::dirname(__FILE__) + '/config/environment'
require 'thin'
require 'ruby-debug'

app = Rack::Builder.new {
  use Rails::Rack::Static
  run Rack::Cascade.new([Sinatra::Application, ActionController::Dispatcher.new])
}.to_app

use Rack::Session::Cookie, :key => '_skinny_board_v1_5_session',
  :secret => 'aba79c7d443291554659101251857984bfa4c5e2c4a8604587ace892f8dc194b07e808760dd69afb268283f852909d434d90181de1b5d7d0e239e2453f876e44'

Rack::Handler::Thin.run app, :Port => 3000, :Host => "0.0.0.0"


# call with: thin start -R config.ru -e development
# -- but its giving an error
#
#require  'config/environment'
#require 'thin'
#
#app = Rack::Builder.new {
#  use Rack::Reloader, 0
#  use Rack::ShowExceptions
#  use Rails::Rack::Static
#  use Rack::Session::Cookie, :key => '_skinny_board_v1_5_session', :domain => 'skinnyboard.local'
#  run Rack::Cascade.new([Sinatra::Application, ActionController::Dispatcher.new])
#}.to_app
#
#run app