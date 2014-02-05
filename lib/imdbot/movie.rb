# encoding: UTF-8

module Imdbot
  class Movie
    STARS = %w(☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆ ☆)

    attr_accessor :title
    attr_accessor :reddit_link
    attr_accessor :comment
    attr_accessor :imdb
    attr_accessor :confidence

    def self.redis_key_namespace
      "imdbot:movies"
    end

    def initialize(imdb, reddit_link)
      @reddit_link = reddit_link
      @imdb = imdb
    end

    def save_to_redis
      REDIS.hset(redis_key, 'reddit_post_url', reddit_link.url)
      REDIS.hset(redis_key, 'reddit_post_title', reddit_link.title)
      REDIS.hset(redis_key, 'imdb_title', imdb.title)
      REDIS.hset(redis_key, 'imdb_url', imdb.url)
      REDIS.hset(redis_key, 'confidence', confidence)
      REDIS.hset(redis_key, 'reddit_comment_id', comment.full_name)
      REDIS.hset(redis_key, 'reddit_link_id', reddit_link.full_name)
    end

    def redis_key
      @redis_key ||= "#{Imdbot::Movie.redis_key_namespace}:#{SecureRandom.hex.to_s}"
    end

    def metacritic
      @metacritic ||= Unirest::post( "https://byroredux-metacritic.p.mashape.com/find/movie",
                                    headers: { "X-Mashape-Authorization" => ::SETTINGS['token'] },
                                    parameters: { "title" => imdb.title }).body['result']
      unless @metacritic
        @metacritic = Unirest::post( "https://byroredux-metacritic.p.mashape.com/find/movie",
                                      headers: { "X-Mashape-Authorization" => ::SETTINGS['token'] },
                                      parameters: { "title" => cleanup(imdb.title) }).body['result']
      end
      @metacritic
    end

    def metacritic_score
      return "[#{metacritic['score']}](#{metacritic['url']})" if metacritic && metacritic['score'] != ''
      '*not found*'
    end

    def plot
      return imdb.plot_summary if imdb.plot_summary
      return '[](#s "' + imdb.plot + '")' if imdb.plot
      "Sorry, there is no plot summary available yet as of #{Time.now}!"
    end

    def url
      @url ||= imdb.url
    end

    def cast_members_list
      ids = imdb.cast_member_ids
      imdb.cast_members[0..5].map.with_index do |member, i|
        "* [#{member}](http://www.imdb.com/name/#{ids[i]})"
      end.join('\n')
    end

    def cast_members
      @cast_members ||= imdb.cast_members
    end

    def cast_member_ids
      @cast_member_ids ||= imdb.cast_member_ids
    end

    def cast
      (0..5).map do |i|
        "* [#{cast_members[i]}](http://www.imdb.com/name/#{cast_member_ids[i]})  " if cast_members[i]
      end.join("\n")
    end

    def rating
      if imdb.rating
        stars = STARS.map.with_index { |x,i| (i+1 < imdb.rating)? '★' : x}.join(' ')
        "(#{imdb.rating}/100) #{stars}"
      else
        "*none*"
      end
    end

    def to_comment
<<-eos
##[#{imdb.title}](#{imdb.url}):
**Directed By:** #{imdb.director.join(' & ')}
*#{imdb.genres.join(' ')}*

####Plot
>#{Sanitize.clean(plot)}  
>[Trailer](#{imdb.trailer_url})
####Cast
#{cast}

Metacritic Score: #{metacritic_score}/**100**  
IMDB Rating: #{rating}  

*Will delete on comment score of -1 or less*  
eos
    end

    def log(logger)
string = <<-eos
#{reddit_link.title.yellow}
(#{confidence.round(2).to_s.cyan}%) #{imdb.title.red}
#{imdb.url.underline}
eos
    logger.info string
    end

    def confidence
      Imdbot::Movie.confidence(imdb.title, reddit_link.title)
    end

    def self.confidence(imdb_title, link_title)
      imdb_title_words = imdb_title.gsub(/[^a-z\s]/i, '').downcase.split
      link_title_words = link_title.gsub(/[^a-z\s]/i, '').downcase.split & imdb_title_words
      link_title_words.count.to_f / imdb_title_words.count.to_f * 100
    end

    private
    def cleanup(title)
      title.gsub(/·/, '-')
    end
  end
end
