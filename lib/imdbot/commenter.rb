# This will eventually happen async via resque
module Imdbot
  class Commenter
    def comment_with_imdb_link(l)
      extract_movie_titles(l.title).each do |title|
        puts l.title
        imdb_title = search_imdb_movies(title).first.title
        puts "I think this movie is #{imdb_title.blue} I searched #{title.red.underline} (#{confidence(imdb_title, title).round(2).to_s.yellow}% confidence)"
        puts ''
      end
    end
  end
end
