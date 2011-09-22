module Lolita::FirstData
  class TestController < Lolita::FirstData::CommonController
    before_filter :render_nothing

    # renders nothing if not in development environment
    def render_nothing
      render :nothing => true unless Rails.env == 'development'
    end

    #FIXME: refactor
    # There are all 12 FirstData tests
    # you should pass them to get production certificates
    # use:  http://localhost:3000/first_data_test/test?nr=1
    # then increment the "nr" until done
    def test
      ip = params[:nr] == '9' ? '192.168.1.2' : request.remote_ip
      # REQUEST
      case params[:nr]
      when /^(1|2|5|6|7|8|10)$/
        session[:payment_data] = {}
        session[:payment_data][:test] = params[:nr]
        rs = @gateway.purchase(100,428,ip,'tests')
        if rs.success?
          session[:payment_data][:trans_id] = rs.params['TRANSACTION_ID']
          return redirect_to(@gateway.go_out)
        else
          return render(:text => "<pre>#{rs.message}</pre>", :satus => 400)
        end
      when /^(3|4|9|11)$/
        session[:payment_data] = {}
        session[:payment_data][:test] = params[:nr]
        rs = @gateway.authorize(100,428,ip,'tests')
        if rs.success?
          session[:payment_data][:trans_id] = rs.params['TRANSACTION_ID']
          return redirect_to(@gateway.go_out)
        else
          return render(:text => "<pre>#{rs.message}</pre>", :satus => 400)
        end
      when /^(12)$/
        session[:payment_data] = {}
        session[:payment_data][:test] = params[:nr]
        rs = @gateway.close_day
        return render(:text => "<pre>#{rs.message}</pre>")
      end

      # RESPONSE
      case session[:payment_data][:test]
      when /^(1|2|5|6|7|8)$/
        rs = @gateway.get_trans_result(ip,session[:payment_data][:trans_id])
        msg = %^
        trans_id: #{session[:payment_data][:trans_id]} <br />
        <pre>#{rs.message}</pre>
        ^
        return render(:text => msg)
      when /^3|4|9$/
        rs = @gateway.complete(session[:payment_data][:trans_id],100,428,ip,'tests')
        msg = %^
        trans_id: #{session[:payment_data][:trans_id]} <br />
        <pre>#{rs.message}</pre>
        ^
        return render(:text => msg)
      when /^(10|11)$/
        if session[:payment_data][:test] == '11'
          @gateway.complete(session[:payment_data][:trans_id],100,428,ip,'tests')
          @gateway.close_day
        end
        rs = @gateway.reverse(session[:payment_data][:trans_id],100)
        msg = %^
        trans_id: #{session[:payment_data][:trans_id]} <br />
        <pre>#{rs.message}</pre>
        ^
        return render(:text => msg)
      end if session[:payment_data]
      render :text => "WRONG REQUEST", :status => 400
    end

  end
end
