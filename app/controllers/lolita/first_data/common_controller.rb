module Lolita::FirstData
  class CommonController < ApplicationController
    include ActiveMerchant::Billing
    before_filter :set_gateway
    skip_before_filter :verify_authenticity_token

    private

    def set_gateway
      @gateway ||= ActiveMerchant::Billing::FirstDataGateway.new(
        :pem => File.open(FIRSTDATA_PEM).read,
        :pem_password => FIRSTDATA_PASS,
        :locale => I18n.locale,
        :payment => set_active_payment
      )
    end

    # returns current payment instance from session
    def set_active_payment
      if session && session[:first_data] && params[:controller] == 'Lolita::FirstData::Transaction'
        @payment ||= session[:first_data][:billing_class].constantize.find(session[:first_data][:billing_id])
      end
    end
  end
end
