module LolitaFirstData
  module Billing
    def self.included(base)
      base.has_many :first_data_transactions, as: :paymentable, class_name: "LolitaFirstData::Transaction", dependent: :destroy
      base.extend ClassMethods
      base.class_eval do
        # returns true if exists transaction with status 'completed'
        # and updates status if needed
        def first_data_paid?
          return true if self.first_data_transactions.where(status: "completed", transaction_code: "000").count >= 1
        end

        def first_data_error_message
          if !first_data_transactions.empty? && first_data_transactions.last.transaction_code
            I18n.t("fd.response.code_#{first_data_transactions.last.transaction_code}", default: I18n.t("fd.unknown_error"))
          end
        end

        # Reverses last completed transaction and updates status to reversed
        def first_data_reverse
          raise("This is already reversed") if self.status == :reversed
          if tr = self.first_data_transactions.where(status: "completed").first
            rs = self.class.gateway.reverse(tr.transaction_id, self.price)
            if rs.success?
              tr.status = :reversed
              tr.transaction_code = rs.params["RESULT_CODE"]
              return tr.save!
            end
          end
        end
      end
    end

    module ClassMethods
      # Closes business day
      # should be executed every day ~midnight
      # Like "ruby script/runner <YourBillingModel>.first_data_close_business_day"
      def first_data_close_business_day
        rs = gateway.close_day
        rs.success? or raise("FirstData close day: #{rs.message}")
      end

      def gateway
        ActiveMerchant::Billing::FirstDataGateway.new(
          pem: File.open(FD_PEM).read,
          pem_password: FD_PASS,
          payment: self
        )
      end
    end
  end
end
