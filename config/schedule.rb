every 1.minutes do
  rake 'scan_hotlinks'
end

every 1.minutes do
  rake 'start_deleter'
end
