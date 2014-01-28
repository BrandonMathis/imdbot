require 'yaml'
require 'bundler'
Bundler.require(:default)

REDIS = Redis.new

require_relative 'imdbot/bot'
require_relative 'imdbot/commenter'

module Imdbot
end
