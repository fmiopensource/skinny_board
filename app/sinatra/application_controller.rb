class SinatraApplicationController
  $:.unshift File.dirname(__FILE__) + '/lib'
  require 'authentication'
  
  get '/' do
    login_required
    redirect '/boards'
  end
end