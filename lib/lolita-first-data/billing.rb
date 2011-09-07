module Lolita
  module FirstData
    module Billing
      def self.included(base)
        base.has_many :fd_transactions, :as => :paymentable, :class_name => "Lolita::FirstData::Transaction", :dependent => :destroy
        base.extend ClassMethods
        base.class_eval do
          # returns true if exists transaction with status 'completed'
          # and updates status if needed
          def paid?
            self.fd_transactions.count(:conditions => {:status => 'completed', :transaction_code => '000'}) >= 1
          end

          def fd_error_message
            if !fd_transactions.empty? && fd_transactions.last.transaction_code
              I18n.t("fd.response.code_#{fd_transactions.last.transaction_code}", :default => I18n.t('fd.unknown_error'))
            end
          end
        end
      end

      module ClassMethods
        # Closes business day
        # should be executed every day ~midnight
        # Like "ruby script/runner <YourBillingModel>.close_business_day"
        def close_business_day
          gw = ActiveMerchant::Billing::FirstDataGateway.new(
            :pem => File.open(FD_PEM).read,
            :pem_password => FD_PASS
          )
          rs =gw.close_day
          rs.success? or raise("FirstData close day: #{rs.message}")
        end
      end
    end
  end
end
