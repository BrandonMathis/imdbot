require 'yaml'
require 'bundler'

Bundler.require(:default) 

REDIS = Redis.new

class Imdbot
  def client
    settings = YAML.load_file('config/settings.yml')
    @client ||= RedditKit::Client.new(settings['username'], settings['password'])
  end

  def scan_hotlinks(subreddit)
    while true do
      client.links(subreddit, category: 'hot', limit: 100).each do |l|
        REDIS.set(l.id, l.permalink)
        REDIS.expire(l.id, 1209600) # expire in 2 weeks
      end
    end
  end
end
