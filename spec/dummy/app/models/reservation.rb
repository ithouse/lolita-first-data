class Reservation < ActiveRecord::Base
  include LolitaFirstData::Billing
  
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
    "EUR"
  end

  # this is called when FirstData merchant is taking some actions
  # there you can save the log message other than the default log file
  def log severity, message
  end
  
  def payment_trx_saved trx
    case trx.status
    when "processing"
      update_column(:status, "payment")
    when "completed"
      update_column(:status, "completed")
    when "rejected"
      update_column(:status, "rejected")
    end
  end
  #-----------------------
end
