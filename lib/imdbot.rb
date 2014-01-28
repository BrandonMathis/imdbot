require 'yaml'
require 'bundler'
Bundler.require(:default)

require_relative 'imdbot/bot'
require_relative 'imdbot/commenter'

REDIS = Redis.new

module Imdbot
end
