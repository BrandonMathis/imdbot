module Imdbot
  class Bot
    QUEUE_NAME = 'imdbot'

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
      client.links('movies', category: 'hot', limit: 50).each do |l|
        queue l
      end
    end


    def scan_links(cat)
      client.subreddits.each do |sr|
        client.links(sr.name, category: cat, limit: 100).each do |l|
          queue l
        end
        sleep 2.5
      end
      sleep 5
    end

    # Queue the reddit link with info in redis
    # Also make record of link ID so we dont make duplicate jobs for a single link
    def queue(l)
      unless REDIS.get(l.id)
        REDIS.set(l.id, l.url)
        REDIS.expire(l.id, 86400 * 3) # Expire in 3 days (in seconds)
        Resque.enqueue(Imdbot::Commenter, l.full_name)
      end
    end
  end
end
