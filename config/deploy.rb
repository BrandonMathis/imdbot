# config valid only for Capistrano 3.1
lock '3.1.0'

# The command to start the Unicorn server
UNICORN = <<-COMMAND.gsub(/\s+/, ' ')
  bundle exec unicorn
    --daemonize
    --env production
    --config-file config/unicorn.rb
COMMAND

namespace :deploy do
  task :restart do
    # Signals the Unicorn server to start a new master process, loading
    # the new release of the codebase. Unicorn will suffix the pid file
    # for the old server process with ".oldbin".
    #
    # As the new processes start up, calls back to before_fork (in
    # config/unicorn.conf) will read the .oldbin pid file and signal the
    # old process to shut down.
    run "kill -s USR2 `cat #{UNICORN_PID}`"
  end

  task :start do
    # Start production Unicorn
    run "cd #{current_path} ; #{UNICORN}"
  end

  task :stop do
    # Shut down the Unicorn server
    run "kill -s QUIT `cat #{UNICORN_PID}`"
  end
end
