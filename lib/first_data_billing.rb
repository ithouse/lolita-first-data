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
            self.fd_transactions.count(:conditions => {:status => 'completed'}) >= 1
          end
        end
      end

      module ClassMethods
        # Closes business day
        # should be executed every day ~midnight
        # Like "ruby script/runner <YourBillingModel>.close_business_day"
        def close_business_day
          gw = ActiveMerchant::Billing::FirstDataGateway.new(
            :pem => File.open(FIRST_DATA_PEM).read,
            :pem_password => FIRST_DATA_PASS,
            :locale => I18n.locale
          )
          rs =gw.close_day
          rs.success? or raise("FirstData close day: #{rs.message}")
        end
      end
    end
  end
end
