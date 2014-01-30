every 5.minutes do
  rake 'watch_hotlinks[imdbot]'
end

every 5.minutes do
  rake 'start_deleter'
end
