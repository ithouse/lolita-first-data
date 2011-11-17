module Lolita::FirstData
  class TransactionController < Lolita::FirstData::CommonController
    before_filter :is_ssl_required

    # should exist
    #   session[:payment_data][:billing_class]
    #   session[:payment_data]:billing_id]
    #   Class should respond to these methods:
    # => :price - cents
    # => :currency - according to http://en.wikipedia.org/wiki/ISO_4217
    # => :description - string that will show up in payment details
    def checkout
      if @payment && !@payment.paid?
        rs = @gateway.purchase(@payment.price,@payment.currency,request.remote_ip,@payment.description)
        if rs.success?
          Lolita::FirstData::Transaction.add(@payment, request, rs)
          redirect_to(@gateway.go_out)
        else
          if request.xhr? || !request.referer
            render :text => I18n.t('fd.purchase_failed'), :status => 400
          else
            redirect_to :back              
          end
        end        
      else
        render :text => I18n.t('fd.wrong_request'), :status => 400
      end
    end

    # there we land after returning from FirstData server
    # then we get transactions result and redirect to your given "finish" path
    def answer
      if trx = Lolita::FirstData::Transaction.where(transaction_id: params[:trans_id]).first
        rs = @gateway.get_trans_result(request.remote_ip,params[:trans_id])
        trx.process_answer(rs, @gateway, request)
        if session[:payment_data] && session[:payment_data][:finish_path]
          redirect_to "#{session[:payment_data][:finish_path]}?merchant=fd&trans_id=#{CGI::escape(params[:trans_id])}"
          return
        end
        # session data lost
        if trx.paymentable.respond_to?('finish_payments_path')
          session[:payment_data] ||= {}
          session[:payment_data][:billing_class] = trx.paymentable.class.to_s
          session[:payment_data][:billing_id]    = trx.paymentable.id
          redirect_to "#{trx.paymentable.finish_payments_path}?merchant=fd&trans_id=#{CGI::escape(params[:trans_id])}"
          return
        end
      else
        render :text => "wrong transaction ID", :status => 400
      end
    end

    private

    # forces SSL in production mode if available
    def is_ssl_required
      ssl_required(:answer, :checkout) if defined?(ssl_required) && (Rails.env == 'production' || Rails.env == 'staging')
    end
  end
end
