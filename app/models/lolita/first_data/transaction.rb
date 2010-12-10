module Lolita::FirstData
  class Transaction < ActiveRecord::Base
    set_table_name :first_data_transactions
    belongs_to :paymentable, :polymorphic => true
    after_save :touch_paymentable
    
    def ip
      IPAddr.new(self[:ip], Socket::AF_INET).to_s
    end

    def ip=(x)
      self[:ip] = IPAddr.new(x).to_i
    end
    
    # add new transaction in Checkout
    def self.add payment, request, rs
      Lolita::FirstData::Transaction.create!(
        :transaction_id => rs.params['TRANSACTION_ID'],
        :status => :processing,
        :paymentable_id => payment.id,
        :paymentable_type => payment.class.to_s,
        :ip => request.remote_ip
      )      
    end
    private
    
    # trigger "fd_trx_saved" on our paymentable model
    def touch_paymentable
      paymentable.fd_trx_saved(self) if paymentable
    end
  end
end