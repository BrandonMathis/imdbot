set :ssh_options, {user: 'bemathis', port: 44}
set :user, 'bemathis'

set :application, 'imdbot'
set :repo_url, 'git@github.com:BrandonMathis/imdbot.git'
set :use_sudo, false

# config/deploy.rb
set :rbenv_type, :user # or :system, depends on your rbenv setup
set :rbenv_ruby, '2.0.0-p247'
set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w{rake gem bundle ruby rails}
set :rbenv_roles, :all # default value

role :web, 'brandonmathis.me'
role :app, 'brandonmathis.me'

set :deploy_to, '/var/www/imdbot'

UNICORN_PID = "#{current_path}/tmp/pids/unicorn.pid"
# The command to start the Unicorn server
UNICORN = <<-COMMAND.gsub(/\s+/, ' ')
  bundle exec unicorn
    --daemonize
    --env production
    --config-file config/unicorn.rb
COMMAND



namespace :deploy do
  after :finishing, :symlink do
    on 'brandonmathis.me' do
      execute "ln -nfs #{shared_path}/tmp/ #{release_path}/tmp"
      execute "ln -nfs #{shared_path}/log/ #{release_path}/log"
    end
  end

  task :restart do
    # Signals the Unicorn server to start a new master process, loading
    # the new release of the codebase. Unicorn will suffix the pid file
    # for the old server process with ".oldbin".
    #
    # As the new processes start up, calls back to before_fork (in
    # config/unicorn.conf) will read the .oldbin pid file and signal the
    # old process to shut down.
    on 'brandonmathis.me' do
      execute "kill -s USR2 `cat #{UNICORN_PID}`"
    end
  end

  task :start do
    # Start production Unicorn
    on 'brandonmathis.me' do
      execute "cd #{current_path} ; #{UNICORN}"
    end
  end

  task :stop do
    # Shut down the Unicorn server
    on 'brandonmathis.me' do
      execute "kill -s QUIT `cat #{UNICORN_PID}`"
    end
  end
end
