require 'spec_helper'

describe Imdbot::Bot do
  before do
    RedditKit::Client.stub(:new)
    Imdbot::Commenter.class_variable_set :@@log, Logger.new('log/test.log')
  end

  describe '.imdb', :vcr do
    let(:imdb_object) { Imdbot::Commenter.imdb(link_title) }

    context 'with keyword' do
      describe 'Movie' do
        let(:link_title) { 'Has anyone see the Movie Inception' }

        it 'gives the movie title' do
          imdb_object.url.should == "http://akas.imdb.com/title/tt1375666/combined"
        end
      end

      describe 'Movie' do
        let(:link_title) { "Your Movie Sucks: After Earth, Part 1" }

        it 'gives the movie title' do
          imdb_object.url.should == "http://akas.imdb.com/title/tt1815862/combined"
        end
      end

      describe 'Film' do
        let(:link_title) { "Vin Diesel new Film Fast Five just came out" }

        it 'gives the movie title' do
          imdb_object.url.should == "http://akas.imdb.com/title/tt1596343/combined"
        end
      end

      describe 'Flick' do
        let(:link_title) { "Has anyone seen the Christopher Nolan flick Interstellar" }

        it 'gives the movie title' do
          imdb_object.url.should == "http://akas.imdb.com/title/tt0816692/combined"
        end
      end

      context 'with some capital letters' do
        let(:link_title) { "Nick Hornby's Long Way Down has been made into a feature film. Here's the first trailer." }

        it 'gives the movie title'
      end
    end

    context 'without keywords' do
      let(:link_title) { "Has anyone seen the Christopher Nolan Interstellar" }

      it 'gives the movie title' do
        imdb_object.should be_false
      end
    end
  end
end
