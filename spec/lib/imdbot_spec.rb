require 'spec_helper'

describe Imdbot do
  let(:bot) { Imdbot.new }
  describe '.extract_movie_titles' do
    context 'with desireable title' do
      let(:link_title) { "This this the 'Movie Title' hello 'Another Movie Title' and \"A Double Quote Movie\"" }

      it 'gets both movie titles' do
        bot.extract_movie_titles(link_title).should include 'Movie Title'
        bot.extract_movie_titles(link_title).should include 'Another Movie Title'
      end

      it 'returns an empty array if there are no movie titles' do
        bot.extract_movie_titles('This has no titles').should == []
      end
    end

    context 'when there are quotes used for conjunction' do
      let(:link_title) { "Scorsese's uses of X's in The Departed to foreshadow characters eventual death" }

      it 'wont use that as a movie title' do
        bot.extract_movie_titles(link_title).should  == []
      end
    end

    context "when there is a double quote with a '" do
      let(:link_title) { "This is the \"Movie of All Decade's\""}

      it 'will get the movie title' do
        bot.extract_movie_titles(link_title).should include "Movie of All Decade's"
      end
    end

    context 'movie with . at the end of the title' do
      let(:link_title) { "I just watched 'The Warriors.'" }

      it 'will remove the . from the end of the title' do
        bot.extract_movie_titles(link_title).should include 'The Warriors'
      end
    end
  end
end
