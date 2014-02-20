module LolitaFirstData
  class Transaction < ActiveRecord::Base
    self.table_name = 'first_data_transactions'
    belongs_to :paymentable, polymorphic: true
    after_save :touch_paymentable
    default_scope -> { order(:id) }
    validates_associated :paymentable

    def ip
      IPAddr.new(self[:ip], Socket::AF_INET).to_s
    end

    def ip=(x)
      self[:ip] = IPAddr.new(x).to_i
    end

    def process_result response
      self.status = response[:result] == 'OK' ? 'completed' : 'failed'
      self.transaction_code = response[:result_code]
      self.save!
    end

    # add new transaction in Checkout
    def self.add payment, request, response
      LolitaFirstData::Transaction.create!(
        transaction_id: response[:transaction_id],
        status: 'processing',
        paymentable_id: payment.id,
        paymentable_type: payment.class.to_s,
        ip: request.remote_ip
      )
    end

    def return_path
      paymentable.first_data_return_path
    end

    private

    # trigger 'first_data_trx_saved' on your paymentable object
    def touch_paymentable
      paymentable.first_data_trx_saved(self)
    end
  end
end
