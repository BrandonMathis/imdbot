require 'spec_helper'

describe Imdbot::Bot do
  before do
    RedditKit::Client.stub(:new)
  end

  describe '#extract_movie_titles' do
    context 'with desireable title' do
      let(:link_title) { "This this the 'Movie Title' hello 'Another Movie Title'" }

      it 'gets both movie titles' do
        Imdbot::Commenter.extract_movie_titles(link_title).should include 'Movie Title'
        Imdbot::Commenter.extract_movie_titles(link_title).should include 'Another Movie Title'
      end

      it 'returns an empty array if there are no movie titles' do
        Imdbot::Commenter.extract_movie_titles('This has no titles').should == []
      end
    end

    context 'when multiple conjugations could be interprited as a movie title' do
      let(:link_title) { "Scorsese's uses of x's in The Departed to foreshadow characters eventual death" }

      it 'wont use that as a movie title' do
        Imdbot::Commenter.extract_movie_titles(link_title).should  == []
      end
    end

    context "when there is a double quote with a '" do
      let(:link_title) { "This is the \"Movie of All Decade's\""}

      it 'will get the movie title' do
        Imdbot::Commenter.extract_movie_titles(link_title).should include "Movie of All Decade's"
      end
    end

    context 'movie with . at the end of the title' do
      let(:link_title) { "I just watched 'The Warriors.'" }

      it 'will remove the . from the end of the title' do
        Imdbot::Commenter.extract_movie_titles(link_title).should include 'The Warriors'
      end
    end

    context 'with quote in the title' do
      let(:link_title) { '"When you make a film that hits the president between the eyes and could shift an election, you become a target," conservative filmmaker Dennis Michael Lynch told Fox News, referring to D\'Souza\'s "2016: Obama\'s America."' }

      it 'will get only the movie title' do
        Imdbot::Commenter.extract_movie_titles(link_title).should include "2016: Obama\'s America"
      end
    end

    context 'with dates in parens' do
      let(:link_title) { 'Just watched the movie "Blue Caprice (2013)" and had some indifferent feelings towards the film.' }

      it 'will get the movies title and date' do
        Imdbot::Commenter.extract_movie_titles(link_title).should include "Blue Caprice (2013)"
      end
    end
  end

  describe '#confidence' do
    subject { Imdbot::Commenter.confidence(imdb_title, query) }

    describe 'with exact match' do
      let(:imdb_title) { "Movie Title (2000)" }
      let(:query) { "Movie Title" }

      it 'give you 100 confidence' do
        subject.should == 100
      end
    end

    describe 'with 1 descripancy' do
      let(:imdb_title) { "The Movie Title (2000)" }
      let(:query) { "Movie Title" }

      it 'give you 90 confidence' do
        subject.should == 90
      end
    end

    describe 'Movie is abbreviation' do
      let(:imdb_title) { "R.I.P.D. (2000)" }
      let(:query) { "we r something" }

      it 'give you 20 confidence' do
        subject.should == 20
      end
    end

    describe 'Movie is singlename' do
      let(:imdb_title) { "Godzilla (I) (1998)" }
      let(:query) { "Gojira" }

      it 'give you 20 confidence' do
        subject.should == 70
      end
    end
  end
end
