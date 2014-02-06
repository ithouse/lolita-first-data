# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
Bundler.load

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

Rails.backtrace_cleaner.remove_silencers!

require "webmock/rspec"
require "pry-byebug"

require "fabrication"
Fabrication::Config.path_prefix = File.dirname(File.expand_path("../", __FILE__))

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

FD_PEM = File.dirname(__FILE__) + "/fixtures/cert.pem"
FD_PASS = "1234"


RSpec.configure do |config|
  config.mock_with :rspec
  config.before(:each) do
    ActiveRecord::Base.connection.execute "DELETE from first_data_transactions"
    ActiveRecord::Base.connection.execute "DELETE from reservations"
  end
end
