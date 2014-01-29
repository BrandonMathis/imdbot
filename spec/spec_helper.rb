Bundler.require(:test)
require_relative '../lib/imdbot'
require 'rspec/core'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
  c.default_cassette_options = { :record => :new_episodes }
  c.configure_rspec_metadata!
  c.filter_sensitive_data('<PASSWORD>') { YAML.load_file('config/settings.yml')['password'] }
end

RSpec.configure do |c|
  c.treat_symbols_as_metadata_keys_with_true_values = true

  c.after(:each) do
    REDIS.keys('imdbot_test:*').each do |k|
      REDIS.del(k)
    end
  end
end
