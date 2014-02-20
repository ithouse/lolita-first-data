# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
ENV["FIRST_DATA_PEM"] = File.dirname(__FILE__) + "/fixtures/cert.pem"
ENV["FIRST_DATA_PASS"] = "1234"

require "rubygems" 
require "bundler/setup"
require "simplecov"
SimpleCov.start "rails"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

Rails.backtrace_cleaner.remove_silencers!

require "rspec/rails"
require "database_cleaner"
require "webmock/rspec"
require "pry-byebug"

require "fabrication"
Fabrication::Config.path_prefix = File.dirname(File.expand_path("../", __FILE__))

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

ActiveMerchant::Billing::Base.mode = :test

RSpec.configure do |config|
  config.mock_with :rspec
  DatabaseCleaner.strategy = :truncation
  config.before(:each) do
    DatabaseCleaner.clean
  end
end
