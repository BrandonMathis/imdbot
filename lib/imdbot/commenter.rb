# This will eventually happen async via resque
module Imdbot
  class Commenter
    @queue = :reddit_movie_post

    def self.perform(link_id)
      @@client = RedditKit::Client.new(::SETTINGS['username'], ::SETTINGS['password'])
      comment_with_movie_details @@client.link(link_id)
    end

    def self.comment_with_movie_details(l)
      extract_movie_titles(l.title).each do |title|
        movie = Imdbot::Movie.new(title, l)
        if ::SETTINGS['live'] = true
          comment(movie) if movie.confidence >= 80
        else
          post_to_file(movie) if movie.confidence >= 80
        end
      end
    end

    def self.comment(movie)
      movie.comment = @@client.submit_comment(movie.reddit_link, movie.to_comment)
      movie.save_to_redis
    end

    def self.post_to_file(movie)
      File.open("tmp/comments/#{Time.now.to_f}.md", 'w') do |f|
        f.write movie.to_comment
      end
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
