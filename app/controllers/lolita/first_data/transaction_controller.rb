module Lolita::FirstData
  class TransactionController < Lolita::FirstData::CommonController
    before_filter :is_ssl_required

    # should exist
    #   session[:first_data][:payment_class]
    #   session[:first_data]:payment_id]
    #   Class should respond to these methods:
    # => :price - cents
    # => :currency - according to http://en.wikipedia.org/wiki/ISO_4217
    # => :description - string that will show up in payment details
    def checkout
      unless @payment.paid?
        rs = @gateway.purchase(@payment.price,@payment.currency,request.remote_ip,@payment.description)
        if rs.success?
          Lolita::FirstData::Transaction.create!(
            :transaction_id => rs.params['TRANSACTION_ID'],
            :status => :processing,
            :paymentable_id => @payment.id,
            :paymentable_type => @payment.class.to_s,
            :ip => request.remote_ip
          )
          return redirect_to(@gateway.go_out)
        end
      end if @payment
      render :text => "Wrong request", :status => 400
    end

    # this is executed after returning from FirstData server
    # then we get transactions result and redirect to your given "finish" path
    def answer
      if fdp = Lolita::FirstData::Transaction.find_by_transaction_id(params[:trans_id])
        sleep 3
        rs = @gateway.get_trans_result(request.remote_ip,params[:trans_id])
        fdp.status = (rs.success?) ? :completed : :rejected
        fdp.transaction_code = rs.params['RESULT_CODE']
        fdp.save
        redirect_to "#{session[:first_data][:finish_path]}?merchant=fd&trans_id=#{params[:trans_id]}"
      else
        render :text => "wrong transaction ID", :status => 400
      end
    end

    private

    # forces SSL in production mode if available
    def is_ssl_required
      ssl_required(:answer, :checkout) if defined?(:ssl_required) && RAILS_ENV == 'production'
    end
  end
end