module Lolita::FirstData
  class TransactionController < Lolita::FirstData::CommonController
    before_filter :is_ssl_required

    # should exist
    #   session[:first_data][:billing_class]
    #   session[:first_data]:billing_id]
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
      if fdp = Lolita::FirstData::Transaction.find_by_transaction_id(params[:trans_id])
        rs = @gateway.get_trans_result(request.remote_ip,params[:trans_id])
        fdp.status = (rs.success?) ? :completed : :rejected
        fdp.transaction_code = rs.params['RESULT_CODE']
        begin 
          fdp.save!
        rescue Exception => e
          fdp_error = "#{e.to_s}\n\n#{$@.join("\n")}"
          if rs.success?
            begin
              @gateway.reverse(fdp.transaction_id,fdp.paymentable.price)            
            rescue Exception => reverse_exception
              reverse_error = "#{reverse_exception.to_s}\n\n#{$@.join("\n")}"
              ExceptionNotifier::Notifier.exception_notification(request.env, reverse_exception).deliver if defined?(ExceptionNotifier)
              @gateway.log :error, reverse_error
            end
          end
          ExceptionNotifier::Notifier.exception_notification(request.env, e).deliver if defined?(ExceptionNotifier)
          @gateway.log :error, fdp_error
        end
        redirect_to "#{session[:first_data][:finish_path]}?merchant=fd&trans_id=#{CGI::escape(params[:trans_id])}"
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