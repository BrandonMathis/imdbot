# This will eventually happen async via resque
module Imdbot
  class Commenter
    @queue = :reddit_movie_post

    def self.perform(link_id)
      @@settings = YAML.load_file('config/settings.yml')
      @@client = RedditKit::Client.new(@@settings['username'], @@settings['password'])
      comment_with_movie_details @@client.link(link_id)
    end

    def self.comment_with_movie_details(l)
      extract_movie_titles(l.title).each do |title|
        movie = Imdbot::Movie.new(title, l)
        movie.save_to_redis
        comment(l, movie.to_comment)
      end
    end

    def self.comment(l, body)
      @@client.submit_comment(l, body)
    end

    # Please explain yourself if you add a regex!!!
    def self.extract_movie_titles(link_title)
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

  end
end
