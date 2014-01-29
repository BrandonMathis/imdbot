module Imdbot
  class Bot
    attr_accessor :username
    attr_accessor :client

    def initialize
      settings = YAML.load_file('config/settings.yml')
      self.username = settings['username']
      self.client = RedditKit::Client.new(username, settings['password'])
    end

    def scan_hotlinks(subreddit)
      client.links(subreddit, category: 'hot', limit: 100).each do |l|
        unless REDIS.get(l.id)
          REDIS.set(l.id, l.url)
          Resque.enqueue(Imdbot::Commenter, l.full_name)
        end
      end
    end
  end
end
