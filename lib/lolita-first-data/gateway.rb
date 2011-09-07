module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class FirstDataGateway < Gateway
      TEST_DOMAIN = 'https://secureshop-test.firstdata.lv'
      LIVE_DOMAIN = 'https://secureshop.firstdata.lv'
      
      # The homepage URL of the gateway
      self.homepage_url = 'http://www.firstdata.lv/'
      
      # The name of the gateway
      self.display_name = 'FirstData'
      
      def initialize(options = {})
        requires!(options, :pem, :pem_password)
        @options = options
        @logger  = Logger.new(defined?(Rails) ? "#{Rails.root}/log/first_data.log" : "/tmp/fd.log", 2, 1024**2)
        @logger.formatter = Lolita::FirstData::LogFormatter.new
        super
      end  

      def authorize(money, currency ,ip, description)
        commit('authorize',{
            'command'       => 'a',
            'msg_type'      => 'DMS',
            'amount'        => money,
            'currency'      => currency,
            'client_ip_addr'=> ip,
            'description'   => description[0,125],
            'language'      => language
          })
      end

      def complete(trans_id,amount,currency,ip,description)
        commit('complete',{
            'command'       => 't',
            'msg_type'      => 'DMS',
            'trans_id'      => trans_id,
            'amount'        => amount,
            'currency'      => currency,
            'client_ip_addr'=> ip,
            'description'   => description[0,125]
          })
      end

      def purchase(money, currency ,ip, description)
        commit('purchase',{
            'command'       => 'v',
            'amount'        => money,
            'currency'      => currency,
            'client_ip_addr'=> ip,
            'description'   => description[0,125],
            'language'      => language
          })
      end                       

      def get_trans_result(ip,trans_id)
        commit('result',{
            'command'       => 'c',
            'trans_id'      => trans_id,
            'client_ip_addr'=> ip
          })
      end

      def reverse(trans_id, amount)
        commit('reverse',{
            'command' => 'r',
            'trans_id' => trans_id,
            'amount' => amount
          })
      end

      def close_day
        commit('close',{
            'command' => 'b'
          })
      end
      
      def go_out
        raise I18n.t('fd.no_trans_id') unless @trans_id
        url = get_domain + "/ecomm/ClientHandler?trans_id=#{CGI.escape @trans_id}"
        url
      end

      # log to default logger and if possible to payment logger
      def log severity, message
        @logger.send(severity,message)
        @options[:payment].log(severity,message) if @options[:payment].respond_to?(:log)
      end
      
      private                       
      
      def language
        I18n.locale.to_s.sub('-','_').downcase
      end
      
      def test?
        ActiveMerchant::Billing::Base.mode == :test
      end

      def get_domain
        test? ? TEST_DOMAIN : LIVE_DOMAIN
      end
      
      def parse(body)
        body.to_s.strip
      end     

      # Return Response object
      # Use the response:
      #   rs.success? - returns true|false
      #   rs.message - returns String with message
      #   rs.params - returns Hash with {'TRANSACTION_ID': 'jl2j4l2j423423=3-3423-4'} or {'RESULT_CODE' => '000'} ...
      def commit(action,parameters)
        url   = get_domain + ":8443/ecomm/MerchantHandler"
        data  = post_data(action, parameters)
        log :info, "#{url} + #{data}"
        rs = parse(post(url, data))
        log :info, rs
        data = {}
        rs.scan(/[0-9A-Z_]+:\s[^\s]+/){|item|
          item =~ /([0-9A-Z_]+):\s(.+)/
          data[$1] = $2
        }
        case action
        when /purchase|authorize/
          @trans_id = data['TRANSACTION_ID']
          Response.new(data['TRANSACTION_ID'],rs,data)
        when /result|reverse|complete|close/
          Response.new(data['RESULT'] == "OK",rs,data)
        end
      end

      # this posts data to FirstData server
      def post url, data, headers = {}
        begin
            ssl_post(url, data, headers).body
        rescue Exception => e
          log :error, "#{e.to_s}\n\n#{$@.join("\n")}"
          "ERROR POSTING DATA"
        end
      end

      def pem_password
        @options[:pem_password]
      end

      def ssl_strict
        false
      end
      
      def post_data(action, parameters = {})
        parameters.to_query
      end

      def self.get_code_msg k
        I18n.t("fd.code._#{k}", :default => I18n.t('fd.unknown_error'))
      end      
    end
  end
end