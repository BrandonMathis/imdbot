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
