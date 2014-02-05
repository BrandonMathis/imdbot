# This will eventually happen async via resque
module Imdbot
  class Commenter
    @queue = :reddit_movie_post

    def self.perform(link_id)
      @@client = RedditKit::Client.new(::SETTINGS['username'], ::SETTINGS['password'])
      @@log = Logger.new('log/info.log')
      comment_with_movie_details @@client.link(link_id)
    end

    def self.comment_with_movie_details(l)
      if imdb_object = extract_film(l.title)
        movie = Imdbot::Movie.new(imdb_object, l)
        if ::SETTINGS['live'] == true
          comment(movie)
          sleep 4
        end
        movie.log @@log
      end
    end

    def self.comment(movie)
      movie.comment = @@client.submit_comment(movie.reddit_link, movie.to_comment)
      movie.save_to_redis
    end

    # Please explain yourself if you add a regex!!!
    def extract_quotes(link_title)
      # Capture all movie titles in double quotes
      # - include the ' chatacter in the capture for contactions like "It's"
      movie_titles = link_title.scan(/"(\S[^"]+\S)"/).flatten.compact

      # Capture all movie titles in single quotes
      # - only if there are no single tick quotes
      if movie_titles.empty?
        movie_titles.concat link_title.scan(/'(\S[^']+\S)'/).flatten.compact
      end

      # Remove non-chars from end of movie title
      # - punctuation seems to mess up IMDB search
      movie_titles.map! { |title| title.gsub(/[\.,:*]$/, '') }

      # Reject potential title if there is not a single uppercase char
      # - this is minly for weeding out titles with multiple conjugations
      movie_titles.select { |title| title =~ /[A-Z]+/ }
    end

    def self.extract_film(link_title)
      imdb_regex = /imdb\.com\/title\/tt([0-9]{7})\//
      if keyword = contains_keywords(link_title)
        Google::Search::Web.new(query: "#{link_title} site:imdb.com -Review" ).each do |q|
          match = q.uri.match(imdb_regex)
          if q.uri =~ imdb_regex
            imdb = Imdb::Movie.new(match[1])
            if imdb.title
              confidence = Imdbot::Movie.confidence(imdb.title, link_title)
              return imdb if confidence > 50
            end
          end
        end
      end
      return false
    end

    def self.log(x)
      @@log = x
    end


    def self.contains_keywords(link_title)
      Imdbot::Keywords.list.each do |keyword|
        return keyword if link_title =~ /#{keyword}/i
      end
      false
    end
  end
end
