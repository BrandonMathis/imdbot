require 'pp'
module Imdbot
  class Deleter
    def scan
      @@client = RedditKit::Client.new(::SETTINGS['username'], ::SETTINGS['password'])
      REDIS.keys("#{Imdbot::Movie.redis_key_namespace}:*").each do |k|
        comment_id = REDIS.hget(k, 'reddit_comment_id')
        link_id = REDIS.hget(k, 'reddit_link_id')
        comment = @@client.comment(comment_id)
        sleep 4
        link = @@client.link(link_id)
        sleep 4
        @@client.delete(comment) if (comment.attributes[:ups] - comment.attributes[:downs]) <= -1
        sleep 4
      end
    end
  end
end
