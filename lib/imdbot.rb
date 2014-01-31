require 'yaml'
require 'bundler'
Bundler.require(:default)

REDIS = Redis.new

require_relative 'imdbot/bot'
require_relative 'imdbot/commenter'
require_relative 'imdbot/movie'
require_relative 'imdbot/keywords'
require_relative 'imdbot/deleter'

::SETTINGS = YAML.load_file('config/settings.yml')

module Imdbot
  RedditKit.middleware = Faraday::RackBuilder.new
end
