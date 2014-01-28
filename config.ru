require 'logger'
#$LOAD_PATH.unshift File.dirname(__FILE__) + '/../../lib'
#require 'app'
require 'resque/server'
require 'yaml'

use Rack::ShowExceptions

AUTH_PASSWORD = ENV['AUTH']

if AUTH_PASSWORD
  Resque::Server.use Rack::Auth::Basic do |username, password|
    password == AUTH_PASSWORD
  end
end

puts 'about to start urlmap'

map '/resque' do
   run Resque::Server.new
end
