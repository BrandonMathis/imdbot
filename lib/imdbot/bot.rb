module Imdbot
  class Bot
    attr_accessor :username
    attr_accessor :client

    def initialize
      self.username = ::SETTINGS['username']
      self.client = RedditKit::Client.new(username, ::SETTINGS['password'])
    end

    def scan_hot_links
      scan_links 'hot'
    end

    def scan_rising_links
      scan_links 'rising'
    end

    def scan_new_links
      scan_links 'new'
    end

    def scan_movie_links
      client.links('movies', category: 'hot', limit: 10).each do |l|
        Resque.enqueue(Imdbot::Commenter, l.full_name)
      end
    end

    def scan_links(cat)
      client.subreddits.each do |sr|
        client.links(sr.name, category: cat, limit: 100).each do |l|
          unless REDIS.get(l.id)
            REDIS.set(l.id, l.url)
            Resque.enqueue(Imdbot::Commenter, l.full_name)
          end
        end
        sleep 1
      end
      sleep 1
    end
  end
end
