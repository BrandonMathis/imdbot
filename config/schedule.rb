set :output,  "log/cron.log"

every 5.minutes do
  rake 'watch_links'
end

every 5.minutes do
  rake 'start_deleter'
end
