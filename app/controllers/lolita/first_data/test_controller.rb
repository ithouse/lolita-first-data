module Lolita::FirstData
  class TestController < Lolita::FirstData::CommonController
    before_filter :render_nothing
    
    # you get there if you are in development environment and access "checkout" action, it's for testing server responses
    def fake_server
      @@return_host = request.env["HTTP_REFERER"].split('/')[2] if request.env["HTTP_REFERER"]
      if params[:command]
        server_handler
      else
        client_handler
      end
    end

    # when "success" button pressed
    def fake_success
      @@fake_result = true
      redirect_to answer_first_data_url(:host => @@return_host, :trans_id => session[:fake_server][:trans_id])
    end

    # when "failure" button pressed
    def fake_failure
      @@fake_result = false
      redirect_to answer_first_data_url(:host => @@return_host, :trans_id => session[:fake_server][:trans_id])
    end

    # renders nothing if not in development environment
    def render_nothing
      render :nothing => true if RAILS_ENV == 'production'
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
        session[:first_data] = {}
        session[:first_data][:test] = params[:nr]
        rs = @gateway.purchase(100,428,ip,'tests')
        if rs.success?
          session[:first_data][:trans_id] = rs.params['TRANSACTION_ID']
          return redirect_to(@gateway.go_out)
        else
          return render(:text => "<pre>#{rs.message}</pre>", :satus => 400)
        end
      when /^(3|4|9|11)$/
        session[:first_data] = {}
        session[:first_data][:test] = params[:nr]
        rs = @gateway.authorize(100,428,ip,'tests')
        if rs.success?
          session[:first_data][:trans_id] = rs.params['TRANSACTION_ID']
          return redirect_to(@gateway.go_out)
        else
          return render(:text => "<pre>#{rs.message}</pre>", :satus => 400)
        end
      when /^(12)$/
        session[:first_data] = {}
        session[:first_data][:test] = params[:nr]
        rs = @gateway.close_day
        return render(:text => "<pre>#{rs.message}</pre>")
      end

      # RESPONSE
      case session[:first_data][:test]
      when /^(1|2|5|6|7|8)$/
        rs = @gateway.get_trans_result(ip,session[:first_data][:trans_id])
        msg = %^
        trans_id: #{session[:first_data][:trans_id]} <br />
        <pre>#{rs.message}</pre>
        ^
        return render(:text => msg)
      when /^3|4|9$/
        rs = @gateway.complete(session[:first_data][:trans_id],100,428,ip,'tests')
        msg = %^
        trans_id: #{session[:first_data][:trans_id]} <br />
        <pre>#{rs.message}</pre>
        ^
        return render(:text => msg)
      when /^(10|11)$/
        if session[:first_data][:test] == '11'
          @gateway.complete(session[:first_data][:trans_id],100,428,ip,'tests')
          @gateway.close_day
        end
        rs = @gateway.reverse(session[:first_data][:trans_id],100)
        msg = %^
        trans_id: #{session[:first_data][:trans_id]} <br />
        <pre>#{rs.message}</pre>
        ^
        return render(:text => msg)
      end if session[:first_data]
      render :text => "WRONG REQUEST", :status => 400
    end

    private

    # acts as server handler
    def server_handler
      data = if params[:command] == 'v'
        "TRANSACTION_ID: #{Array.new(28) { (('a'..'z').to_a + (0..9).to_a).choice }.join}"
      elsif params[:command] == 'c'
        if @@fake_result
          "RESULT: OK RESULT_CODE: 000"
        else
          "RESULT: FAILED RESULT_CODE: #{ActiveMerchant::Billing::FirstDataGateway::RESPONSE_CODES.keys.collect{|k| k unless k == "000"}.choice}"
        end
      else
        "RESULT: OK RESULT_CODE: 000"
      end
      render :text => data
    end
    
    # acts as client handler
    def client_handler
      if trans_id = params["/ecomm/ClientHandler?trans_id"]
        session[:fake_server] ||= {}
        session[:fake_server][:trans_id] = trans_id
        render :layout => false
      end
    end
  end
end
