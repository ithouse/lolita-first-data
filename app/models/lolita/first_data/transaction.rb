module Lolita::FirstData
  class Transaction < ActiveRecord::Base
    self.table_name = 'first_data_transactions'

    belongs_to :paymentable, :polymorphic => true
    after_save :touch_paymentable

    def ip
      IPAddr.new(self[:ip], Socket::AF_INET).to_s
    end

    def ip=(x)
      self[:ip] = IPAddr.new(x).to_i
    end

    def process_answer rs, gateway, request
      self.status = (rs.success?) ? 'completed' : 'rejected'
      self.transaction_code = rs.params['RESULT_CODE']
      begin
        self.save!
      rescue Exception => e
        fdp_error = "#{e.to_s}\n\n#{$@.join("\n")}"
        if rs.success?
          begin
            gateway.reverse(fdp.transaction_id,fdp.paymentable.price)
          rescue Exception => reverse_exception
            reverse_error = "#{reverse_exception.to_s}\n\n#{$@.join("\n")}"
            ExceptionNotifier::Notifier.exception_notification(request.env, reverse_exception).deliver if defined?(ExceptionNotifier)
            gateway.log :error, reverse_error
          end
        end
        ExceptionNotifier::Notifier.exception_notification(request.env, e).deliver if defined?(ExceptionNotifier)
        gateway.log :error, fdp_error
        false
      end
    end

    # add new transaction in Checkout
    def self.add payment, request, rs
      Lolita::FirstData::Transaction.create!(
        :transaction_id => rs.params['TRANSACTION_ID'],
        :status => 'processing',
        :paymentable_id => payment.id,
        :paymentable_type => payment.class.to_s,
        :ip => request.remote_ip
      )      
    end

    private
    
    # trigger "payment_trx_saved" on our paymentable model
    def touch_paymentable
      paymentable.payment_trx_saved(self) if paymentable
    end
  end
end
