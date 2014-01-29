every 1.minutes do
  rake 'scan_hotlinks[imdbot]'
end

every 1.minutes do
  rake 'start_deleter'
end
