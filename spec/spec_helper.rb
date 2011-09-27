require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'active_record'
require 'rspec'
require 'webmock/rspec'
require 'fabrication'
require 'logger'
require 'ruby-debug'
require 'lolita-first-data'
require 'support/rails'

FD_PEM = File.dirname(__FILE__) + "/cert.pem"
FD_PASS = "1234"

# load transaction module
require File.dirname(__FILE__)+'/../app/models/lolita/first_data/transaction.rb'

ActiveRecord::Base.logger = Logger.new(File.open("#{File.dirname(__FILE__)}/database.log", 'w+'))
ActiveRecord::Base.establish_connection({ :database => ":memory:", :adapter => 'sqlite3', :timeout => 500 })

# setup I18n
I18n.load_path += Dir[File.join(File.dirname(__FILE__), '..', 'config', 'locales', '*.{rb,yml}').to_s]
I18n.available_locales = [:en,:lv]
I18n.default_locale = :en
I18n.locale = :en

# load transaction module
require File.dirname(__FILE__)+'/../app/models/lolita/first_data/transaction.rb'

# Add models
ActiveRecord::Schema.define do
  create_table :first_data_transactions do |t|
    t.string :transaction_id, :length => 28
    t.string :transaction_code, :length => 3
    t.string :status, :default => 'processing'
    t.references :paymentable, :polymorphic => true
    t.string :ip, :length => 10

    t.timestamps
  end

  create_table :reservations do |t|
    t.integer :full_price
    t.string :status

    t.timestamps
  end
end

class Reservation < ActiveRecord::Base
  include Lolita::FirstData::Billing
  
  def paid?
    first_data_paid?
  end

  # Methods for FirstData
  #-----------------------
  def price
    full_price
  end

  # string up to 125 symbols
  def description
    "testing"
  end

  # returns 3 digit string according to http://en.wikipedia.org/wiki/ISO_4217
  def currency
    "840"
  end

  # this is called when FirstData merchant is taking some actions
  # there you can save the log message other than the default log file
  def log severity, message
  end
  
  def payment_trx_saved trx
    case trx.status
    when 'processing'
      update_attribute(:status, 'payment')
    when 'completed'
      update_attribute(:status, 'completed')
    when 'rejected'
      update_attribute(:status, 'rejected')
    end
  end
  #-----------------------
end

RSpec.configure do |config|
  config.mock_with :rspec
  config.before(:each) do
    ActiveRecord::Base.connection.execute "DELETE from first_data_transactions"
    ActiveRecord::Base.connection.execute "DELETE from reservations"
  end
end
