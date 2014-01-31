module Imdbot
  class Bot
    attr_accessor :username
    attr_accessor :client

    def initialize
      self.username = ::SETTINGS['username']
      self.client = RedditKit::Client.new(username, ::SETTINGS['password'])
    end

    def scan_hotlinks
      client.subreddits.each do |sr|
        client.links(sr.name, category: 'rising', limit: 100).each do |l|
          unless REDIS.get(l.id)
            REDIS.set(l.id, l.url)
            Resque.enqueue(Imdbot::Commenter, l.full_name)
          end
        end
      end
    end
  end
end
