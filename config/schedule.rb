every 5.minutes do
  rake 'scan_hotlinks[imdbot]'
end

every 5.minutes do
  rake 'start_deleter'
end
