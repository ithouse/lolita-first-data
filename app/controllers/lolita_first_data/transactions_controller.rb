module LolitaFirstData
  class TransactionsController < LolitaFirstData::ApplicationController
    protect_from_forgery except: :answer
    before_filter :is_ssl_required
    before_filter :set_active_payment, :check_valid_payment, only: :checkout

    # We get transaction_id from FirstData and if ok, then we redirect to web interface
    def checkout
      response = gateway.purchase(payment.price,
                                  currency: payment.currency.to_s,
                                  client_ip_addr: request.remote_ip,
                                  description: payment.description,
                                  language: payment.first_data_language)
      if response[:transaction_id]
        trx = LolitaFirstData::Transaction.add(payment, request, response)
        redirect_to gateway.redirect_url(trx.transaction_id)
      else
        if request.xhr? || !request.referer
          render text: I18n.t('fd.purchase_failed'), status: 400
        else
          flash[:error] = I18n.t('fd.purchase_failed')
          redirect_to :back
        end
      end
    ensure
      LolitaFirstData.logger.info("[#{session_id}][#{payment.id}][checkout] #{response}")
    end

    # there we land after returning from FirstData server
    # then we get transactions result and redirect to your given "finish" path
    def answer
      if trx = LolitaFirstData::Transaction.where(transaction_id: params[:trans_id]).first
        response = gateway.result(params[:trans_id], client_ip_addr: request.remote_ip)
        trx.process_result(response)
        redirect_to trx.return_path
      else
        render text: I18n.t('fd.wrong_request'), status: 400
      end
    ensure
      if trx
        LolitaFirstData.logger.info("[#{session_id}][#{trx.paymentable_id}][answer] #{response}")
      end
    end

    private

    # payment should not be paid
    def check_valid_payment
      if payment.paid?
        render text: I18n.t("bank_link.wrong_request"), status: 400
      end
    end

    # forces SSL in production mode if available
    def is_ssl_required
      ssl_required(:answer, :checkout) if defined?(ssl_required) && (Rails.env.production? || Rails.env.staging?)
    end

    def session_id
      request.session_options[:id]
    end
  end
end
