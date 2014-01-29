set :ssh_options, {user: 'bemathis', port: 44}
set :user, 'bemathis'

set :application, 'imdbot'
set :repo_url, 'git@github.com:BrandonMathis/imdbot.git'
set :use_sudo, false

set :rbenv_type, :user
set :rbenv_ruby, '2.0.0-p247'

role :web, 'brandonmathis.me'
role :app, 'brandonmathis.me'

set :deploy_to, '/var/www/imdbot'
