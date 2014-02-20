require "ipaddr"
require "active_merchant_first_data"
require "lolita_first_data/engine"
require "lolita_first_data/version"
require "lolita_first_data/custom_logger"
require "lolita_first_data/billing"

module LolitaFirstData
  mattr_accessor :custom_logger

  def self.logger
    unless @logger
      @logger = custom_logger ? custom_logger : default_logger
    end
    @logger
  end

  protected

  def self.default_logger
    logger = Logger.new(Rails.root.join('log', 'lolita_first_data.log'))
    logger.formatter = LolitaFirstData::LogFormatter.new
    logger
  end
end
