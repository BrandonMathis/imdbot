module Imdbot
  class Movie
    attr_accessor :title
    attr_accessor :reddit_link

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
    end

    def redis_key
      @redis_key ||= "imdbot:movies:#{SecureRandom.hex.to_s}"
    end

    def to_comment
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
      imdb_title = imdb.title.gsub(/\(\d+\)/, '') # Remove Date
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