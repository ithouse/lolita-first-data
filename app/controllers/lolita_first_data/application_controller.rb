module LolitaFirstData
  class ApplicationController < ActionController::Base
    attr_reader :payment
    include ActiveMerchant::Billing
    skip_before_filter :verify_authenticity_token

    private

    def gateway
      @gateway ||= ActiveMerchant::Billing::FirstDataGateway.new(
        :pem => File.open(ENV['FIRST_DATA_PEM']).read,
        :pem_password => ENV['FIRST_DATA_PASS']
      )
    end

    # returns current payment instance from session
    def set_active_payment
      @payment ||= session[:payment_data][:billing_class].constantize.find(session[:payment_data][:billing_id])
    rescue
      render text: "No valid payment", status: 400
    end
  end
end
