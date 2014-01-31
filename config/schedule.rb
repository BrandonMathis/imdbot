env :MAILTO, settings = YAML.load_file('config/settings.yml')['email']
set :output,  {:standard => "log/cron.log"}

every 5.minutes do
  rake 'watch_links'
end

every 5.minutes do
  rake 'start_deleter'
end
