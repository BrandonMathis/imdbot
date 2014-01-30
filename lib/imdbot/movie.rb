module Imdbot
  class Movie
    attr_accessor :title
    attr_accessor :reddit_link
    attr_accessor :comment

    def self.redis_key_namespace
      "imdbot:movies"
    end

    def initialize(title, reddit_link)
      @title = title
      @reddit_link = reddit_link
    end

    def save_to_redis
      REDIS.hset(redis_key, 'reddit_post_url', reddit_link.url)
      REDIS.hset(redis_key, 'reddit_post_title', reddit_link.title)
      REDIS.hset(redis_key, 'title', title)
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
      @metacritic ||= Unirest::post( "https://byroredux-metacritic.p.mashape.com/find/movie", headers: { "X-Mashape-Authorization" => ::SETTINGS['token'] }, parameters: { "title" => imdb.title.gsub(/\s\(\d+\)/, '') }).body['result']
    end

    def metacritic_score
      return "[#{metacritic['score']}](#{metacritic['url']})" if metacritic
      '*not found*'
    end

    def to_comment
<<-eos
##[#{imdb.title}](#{imdb.url}):

>#{plot}

Metacritic Score: #{metacritic_score}

*Will delete on comment score of -1 or less*  
eos
    end

    def plot
      return imdb.plot_summary if imdb.plot_summary
      return '[](#s "' + imdb.plot + '")' if imdb.plot
      "Sorry, there is no plot summary available yet as of #{Time.now}!"
    end

    def imdb
      @imdb ||= search_imdb_movies(title)
    end

    def url
      @url ||= imdb.url
    end

    def search_imdb_movies(query_string)
      Imdb::Search.new(query_string).movies.first
    end

    def confidence
      confidence = 100
      imdb_title = imdb.title.gsub(/\(.+\)/, '') # Remove Date
      case imdb_title
      when /([\w]{1}[\.]{1})/ # Split for abbreviation titles like 'R.I.P.D'
        imdb_title_words = imdb_title.split('.')
      else
        imdb_title_words = imdb_title.split.map!{ |word| word.downcase }
      end
      title_words = title.split.map!{ |word| word.downcase }
      confidence -= (imdb_title_words - title_words).size * 10
      confidence -= (title_words - imdb_title_words).size * 10
      confidence = 0 if confidence < 0
      confidence
    end
  end
end
