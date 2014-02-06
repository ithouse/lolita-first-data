module LolitaFirstData
  class ApplicationController < ActionController::Base
    include ActiveMerchant::Billing
    before_filter :set_gateway
    skip_before_filter :verify_authenticity_token

    private

    def set_gateway
      @gateway ||= ActiveMerchant::Billing::FirstDataGateway.new(
        :pem => File.open(FD_PEM).read,
        :pem_password => FD_PASS,
        :payment => set_active_payment
      )
    end

    # returns current payment instance from session
    def set_active_payment
      if session && session[:payment_data] && params[:controller] == "LolitaFirstData::Transaction"
        @payment ||= session[:payment_data][:billing_class].constantize.find(session[:payment_data][:billing_id])
      end
    end
    
  end
end
