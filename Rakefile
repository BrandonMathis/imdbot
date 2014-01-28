require 'rake'
require_relative 'lib/imdbot'
require "resque/tasks"

task :watch_hotlinks do
  bot = Imdbot::Bot.new
  bot.scan_hotlinks 'movies'
end
