require 'rake'
require_relative 'lib/imdbot'
require "resque/tasks"

desc "Will obtain links from all default subreddits to be scanned"
task :watch_links do
  bot = Imdbot::Bot.new
  bot.scan_rising_links
  bot.scan_new_links
end

task :start_deleter do
  # Imdbot::Deleter.new.scan
end

desc "Will obtain links from /r/movies subreddit to be scanned"
task :get_movie_links do
  Imdbot::Bot.new.scan_movie_links
end
