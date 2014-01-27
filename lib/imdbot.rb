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
      puts "I think this movie is #{imdb_title.blue} I searched #{title.red.underline}"
      puts ''
    end
  end

  # Please explain yourself if you add a regex!!!
  def extract_movie_titles(link_title)
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
    movie_titles.map! { |title| title.gsub(/\W$/, '') }

    # Reject potential title if there is not a single uppercase char
    # - this is minly for weeding out titles with multiple conjugations
    movie_titles.select { |title| title =~ /[A-Z]+/ }
  end

  def search_imdb_movies(query_string)
    Imdb::Search.new(query_string).movies
  end
end
