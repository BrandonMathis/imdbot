require 'rake'
require_relative 'lib/imdbot'
require "resque/tasks"

task :watch_links do
  bot = Imdbot::Bot.new
  bot.scan_rising_links
  bot.scan_new_links
end

task :start_deleter do
  Imdbot::Deleter.new.scan
end
