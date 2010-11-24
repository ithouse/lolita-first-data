module Lolita::FirstData
  class Transaction < ActiveRecord::Base
    set_table_name :first_data_transactions
    belongs_to :paymentable, :polymorphic => true
    
    def ip
      IPAddr.new(self[:ip], Socket::AF_INET).to_s
    end

    def ip=(x)
      self[:ip] = IPAddr.new(x).to_i
    end
  end
end