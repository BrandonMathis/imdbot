require 'yaml'
require 'bundler'

Bundler.require(:default) 

REDIS = Redis.new

class Imdbot
  def client
    settings = YAML.load_file('config/settings.yml')
    @client ||= RedditKit::Client.new(settings['username'], settings['password'])
  end

  def scan_hotlinks(subreddit)
    while true do
      client.links(subreddit, category: 'hot', limit: 100).each do |l|
        REDIS.set("imdbot:links:#{l.id}", l.permalink)
        REDIS.expire(l.id, 1209600) # expire in 2 weeks
        comment_with_imdb_link(l)
      end
    end
  end

  def comment_with_imdb_link(l)
    extract_movie_titles(l.title).each do |title|
      puts l.title
      imdb_title = search_imdb_movies(title).first.title
      puts "I think this movie is (#{imdb_title}) I searched (#{title})"
    end
  end

  # Please explain yourself if you add a regex!!!
  def extract_movie_titles(link_title)
    # Capture all movie titles in single quotes
    movie_titles = link_title.scan(/'(\w[\w\s\w]+\S)'/).flatten.compact
    # Capture all movie titles in double quotes
    # - include the ' chatacter in the capture for contactions like "It's"
    movie_titles.concat link_title.scan(/"(\w[\w\s\w']+\S)"/).flatten.compact
    # Remove non-chars from end of movie title
    movie_titles.map! { |title| title.gsub(/\W$/, '') }
    # Reject the movie title if it does not begin with a capital letter
    movie_titles.reject { |title| title =~/^[a-z]+/ }
  end

  def search_imdb_movies(query_string)
    Imdb::Search.new(query_string).movies
  end
end
