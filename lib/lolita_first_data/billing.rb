module LolitaFirstData
  module Billing
    def self.included(base)
      base.has_many :first_data_transactions, as: :paymentable, class_name: 'LolitaFirstData::Transaction', dependent: :destroy
      base.extend ClassMethods
      base.class_eval do

        # Payment description
        def description
          raise 'Redefine this method in your billing model.'
        end

        # Price of payment in cents
        def price
          raise 'Redefine this method in your billing model.'
        end

        # Currency as 3 letter code as in ISO 4217
        def currency
          raise 'Redefine this method in your billing model.'
        end

        def first_data_trx_saved trx
          raise 'This should be inplemented on your paymentable class'
        end

        def first_data_return_path
          raise 'This should be inplemented on your paymentable class'
        end

        # Add this to your paid? method along with other payment methods
        # Example:
        #     def paid?
        #       paypal_paid? || first_data_paid?
        #     end
        def first_data_paid?
          self.first_data_transactions.where(status: 'completed', transaction_code: '000').count >= 1
        end

        def first_data_error_message
          if trx = first_data_transactions.last and trx.transaction_code != '000'
            I18n.t("fd.response.code_#{trx.transaction_code}", default: I18n.t('fd.unknown_error'))
          end
        end

        # web interface will open in this language
        def first_data_language
          I18n.locale.to_s.sub('-','_').downcase
        end

        # Reverses last completed transaction and updates status to reversed
        def first_data_reverse
          raise('This is already reversed') if self.status.to_s == 'reversed'
          if trx = self.first_data_transactions.where(status: 'completed').first
            response = self.class.gateway.refund(self.price, trx.transaction_id)
            if response[:result] == 'OK'
              trx.status = 'reversed'
              trx.transaction_code = response[:result_code]
              return trx.save!
            end
          end
        end
      end
    end

    module ClassMethods
      # Closes business day
      # should be executed every day ~midnight
      # Like 'ruby script/runner <YourBillingModel>.first_data_close_business_day'
      def first_data_close_business_day
        gateway.close_day
      end

      def gateway
        @gateway ||= ActiveMerchant::Billing::FirstDataGateway.new(
          pem: File.open(ENV['FIRST_DATA_PEM']).read,
          pem_password: ENV['FIRST_DATA_PASS']
        )
      end
    end
  end
end
