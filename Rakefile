require 'rake'
require_relative 'lib/imdbot'
require "resque/tasks"

task :watch_hotlinks, :subreddit do |t, args|
  bot = Imdbot::Bot.new
  bot.scan_hotlinks args[:subreddit]
end

task :start_deleter do
  Imdbot::Deleter.new.scan
end
