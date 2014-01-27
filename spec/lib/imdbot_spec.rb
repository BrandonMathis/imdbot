require 'spec_helper'

describe Imdbot do
  let(:bot) { Imdbot.new }
  describe '.extract_movie_titles' do
    context 'with desireable title' do
      let(:link_title) { "This this the 'Movie Title' hello 'Another Movie Title'" }

      it 'gets both movie titles' do
        bot.extract_movie_titles(link_title).should include 'Movie Title'
        bot.extract_movie_titles(link_title).should include 'Another Movie Title'
      end

      it 'returns an empty array if there are no movie titles' do
        bot.extract_movie_titles('This has no titles').should == []
      end
    end

    context 'when multiple conjugations could be interprited as a movie title' do
      let(:link_title) { "Scorsese's uses of x's in The Departed to foreshadow characters eventual death" }

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

    context'with quote in the title' do
      let(:link_title) { '"When you make a film that hits the president between the eyes and could shift an election, you become a target," conservative filmmaker Dennis Michael Lynch told Fox News, referring to D\'Souza\'s "2016: Obama\'s America."' }

      it 'will get only the movie title' do
        bot.extract_movie_titles(link_title).should include "2016: Obama\'s America"
      end
    end
  end
end
