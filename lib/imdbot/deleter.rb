require 'pp'
module Imdbot
  class Deleter
    def scan
      @@settings = YAML.load_file('config/settings.yml')
      @@client = RedditKit::Client.new(@@settings['username'], @@settings['password'])
      REDIS.keys("#{Imdbot::Movie.redis_key_namespace}:*").each do |k|
        comment_id = REDIS.hget(k, 'reddit_comment_id')
        link_id = REDIS.hget(k, 'reddit_link_id')
        comment = @@client.comment(comment_id)
        link = @@client.link(link_id)
        @@client.delete(comment) if (comment.attributes[:ups] - comment.attributes[:downs]) <= 0
      end
    end
  end
end
