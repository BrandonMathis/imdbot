require 'spec_helper'

describe Imdbot::Movie, :vcr do
  let(:settings) { YAML.load_file('config/settings.yml') }
  let(:client) { RedditKit::Client.new(settings['username'], settings['password']) }
  let!(:reddit_link) { client.link('t3_1wdeb1') }

  subject { Imdbot::Movie.new('Star Wars', reddit_link) }

  describe '#url' do
    let(:uri) { URI.parse(subject.url) }

    it 'gives a url' do
      uri.host.should == 'akas.imdb.com'
    end
  end

  describe '#save_to_redis' do
    before do
      Imdbot::Movie.any_instance.stub(:redis_key).and_return("imdbot_test:imdbot:movies:#{SecureRandom.hex.to_s}")
      subject.save_to_redis
    end

    it 'saves the reddit post title' do
      REDIS.hget(subject.redis_key, 'reddit_post_title').should == subject.reddit_link.title
    end

    it 'saves the reddit post url' do
      REDIS.hget(subject.redis_key, 'reddit_post_url').should == subject.reddit_link.url
    end

    it 'saves the title' do
      REDIS.hget(subject.redis_key, 'title').should == subject.title
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

  describe '#to_comment' do
    it 'exports a string of markdown formatted movie data'
  end
end
