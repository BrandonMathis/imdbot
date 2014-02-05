# encoding: UTF-8

require 'spec_helper'

describe Imdbot::Movie, :vcr do
  let(:settings) { YAML.load_file('config/settings.yml') }
  let(:client) { RedditKit::Client.new(settings['username'], settings['password']) }
  let(:movie_title) { "Star Wars" }
  let(:reddit_link) { client.link('t3_1wdeb1') }
  let(:imdb) { Imdb::Movie.new('0076759') }

  subject { Imdbot::Movie.new(imdb, reddit_link) }

  describe '#url' do
    let(:uri) { URI.parse(subject.url) }

    it 'gives a url' do
      uri.host.should == 'akas.imdb.com'
    end
  end

  describe '#save_to_redis' do
    before do
      Imdbot::Movie.any_instance.stub(:redis_key).and_return("imdbot_test:imdbot:movies:#{SecureRandom.hex.to_s}")
      Imdbot::Movie.any_instance.stub_chain(:comment, :full_name).and_return("Junk")
      subject.save_to_redis
    end

    it 'saves the reddit post title' do
      REDIS.hget(subject.redis_key, 'reddit_post_title').should == subject.reddit_link.title
    end

    it 'saves the reddit post url' do
      REDIS.hget(subject.redis_key, 'reddit_post_url').should == subject.reddit_link.url
    end

    it 'saves the imdb title' do
      REDIS.hget(subject.redis_key, 'imdb_title').should == subject.imdb.title
    end

    it 'saves the imdb url' do
      REDIS.hget(subject.redis_key, 'imdb_url').should == subject.imdb.url
    end

    it 'saves the confidence level' do
      REDIS.hget(subject.redis_key, 'confidence').should == subject.confidence.to_s
    end

    it 'saves the if a comment was sent to reddit'
    it 'saves the link to the reddit comment'
  end

  describe '#imdb' do
    let(:reddit_link) { client.link("t3_1wk6v2") }
    let(:movie_title) { "Wall-E" }
    let(:imdb) { Imdb::Movie.new('0910970') }

    it 'gives the title if there are utf-8 characters in title' do
      subject.imdb.title.should == 'WALL·E'
    end
  end

  describe '#metacritic' do
    let(:reddit_link) { client.link("t3_1wk6v2") }
    let(:movie_title) { "Wall-E" }
    let(:imdb) { Imdb::Movie.new('0910970') }

    it 'gives the metacritic score' do
      subject.metacritic['score'].should == '94'
    end

    it 'gives a metacritic score link' do
      subject.metacritic_score.should_not be_nil
    end
  end

  describe '#confidence' do
    let(:link_title) { "Has anyone seen the film Ways to Die in the West yet?" }
    let(:imdb_title) { "A Million Ways to Die in the West" }

    it 'gives confidence' do
      Imdbot::Movie.confidence(imdb_title, link_title).should == 75.0
    end

    context 'when Se7en' do
      let(:link_title) { "What is *worst* casting choice you've ever seen in a movie?" }
      let(:imdb_title) { 'Se7en' }

      it 'gives confidence' do
        Imdbot::Movie.confidence(imdb_title, link_title).should == 0
      end
    end
  end
end
