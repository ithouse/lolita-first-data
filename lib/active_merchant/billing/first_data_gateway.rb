module ActiveMerchant #:nodoc:
  module Billing #:nodoc:
    class FirstDataGateway < Gateway
      DEBUG_DOMAIN= 'http://localhost:3001/first_data_test/fake_server/?'
      TEST_DOMAIN = 'https://secureshop-test.firstdata.lv'
      LIVE_DOMAIN = 'https://secureshop.firstdata.lv'
      LANGUAGE = 'en'
      RESPONSE_CODES = {
        "914"=>"Atteikts, nevar atgriezties pie\n  oriģinālās transakcijas",
        "003"=>"Apstirināts VIP",
        "102"=>"Atteikts, aizdomas par krāpniecību",
        "201"=>"Atņemt, beidzies kartes derīguma termiņš",
        "300"=>"Status message: file action successful",
        "123"=>"Atteikts, pārsniegts naudas\n  izdošanas biežuma limits",
        "XXX"=>"Code to be replaced by card status code or stoplist insertion reason code",
        "915"=>"Atteikts, rekonsilācijas pārslēgšana\n  vai kontrolpunkta kļūda",
        "004"=>"Apstiprināts, koriģēts 3 celiņš",
        "103"=>"Atteikts, kartes pieņēmējam\n  jāsazinās ar pieņēmējbanku",
        "202"=>"Atņemt, aizdomas par krāpšanu",
        "301"=>"Status message: file action not supported by receiver",
        "400"=>"Apstiprināts (Reversēšanai)",
        "124"=>"Atteikts, likuma pārkāpums",
        "916"=>"Atteikts, nepareizs MAC",
        "005"=>"Apstiprināts, konta tipu norāda\n  kartes izdevējs",
        "104"=>"Atteiks, karte ar ierobežojumu",
        "203"=>"Atņemt, kartes pieņēmējam jāsazinās\n  ar pieņēmējbanku",
        "302"=>"Status message: unable to locate record on file",
        "500"=>"Status message: reconciled, in balance",
        "125"=>"Atteikts, karte nav derīga",
        "917"=>"Atteikts, MAC atslēgu\n  sinhronizācijas kļūda",
        "600"=>"Apstiprināts (Administratīvais info)",
        "126"=>"Atteikts, nepareizs PIN bloks",
        "006"=>"Apstiprināts par daļēju summu, konta\n  tipu norāda kartes izdevējs",
        "105"=>"Atteikts, kartes pieņēmējam jāzvana\n  izdevējbankas drošības departamentam",
        "204"=>"Atņemt, karte ar ierobežojumiem",
        "303"=>"Status message: duplicate record, old record replaced",
        "501"=>"Status message: reconciled, out of balance",
        "700"=>"Apstiprināts (komisiju savākšana)",
        "601"=>"Status message: impossible to trace back original transaction",
        "007"=>"Apstiprināts, koriģēts ICC",
        "106"=>"Atteikts, pieļaujamais PIN\n  ievadīšanas skaits izsmelts",
        "205"=>"Atņemt, kartes pieņēmējam jāzvana\n  izdevējbankas drošības departamentam",
        "304"=>"Status message: file record field edit error",
        "502"=>"Status message: amount not reconciled, totals provided",
        "127"=>"Atteikts, PIN garuma kļūda",
        "920"=>"Atteikts, drošības programmatūras\n  kļūda, mēģiniet atkārtoti",
        "918"=>"Atteikts, nav\n  lietojamu transporta atslēgu ",
        "800"=>"Apstiprināts (Tīkla vadībai)",
        "602"=>"Status message: invalid transaction reference number",
        "107"=>"Atteikts, griezties pie kartes\n  izdevējbankas",
        "206"=>"Atņemt, pārsniegts atļauto PIN\n  ievažu skaits",
        "305"=>"Status message: file locked out",
        "503"=>"Status message: totals for reconciliation not available",
        "128"=>"Atteikts, PIN atslēgu sinhronizācijas kļūda",
        "921"=>"Atteikts, drošības programmatūras kļūda",
        "919"=>"Atteikts, kriptēšanas atslēgu\n  sinhronizācijas kļūda",
        "900"=>"Paziņojums atzīts, pieņemt bez\n  finansiālas atbildības",
        "603"=>"Status message: reference number/PAN incompatible",
        "108"=>"Atteikts, griezties pie kartes\n  izdevējbankas, īpaši nosacījumi",
        "207"=>"Atņemt, īpaši nosacījumi",
        "306"=>"Status message: file action not successful", 
        "504"=>"Status message: not reconciled, totals provided",
        "129"=>"Atteikts, aizdomas par kartes viltojumu",
        "922"=>"Atteikts, ziņojuma numurs neatbilst\n  secībai",
        "901"=>"Paziņojums atzīts, pieņemt ar\n  finansiālu atbildību",
        "604"=>"Status message: POS photograph is not available",
        "110"=>"Atteikts, nepareiza summa",
        "109"=>"Atteikts, nepareizs tirgotājs",
        "208"=>"Atņemt, pazaudēta karte",
        "307"=>"Status message: file data format error",
        "923"=>"Pieprasījums tiek apstrādāts",
        "902"=>"Atteikts, nepareiza transakcija",
        "605"=>"Status message: requested item supplied",
        "111"=>"Atteikts, nepareizs kartes numurs",
        "210"=>"Atņemt, aizdomas par kartes viltojumu",
        "209"=>"Atņemt, zagta karte",
        "308"=>"Status message: duplicate record, new record rejected",
        "903"=>"Vēlreiz ievadi transakciju",
        "606"=>"Status message: request cannot be\n  fulfilled - required documentation is not available",
        "112"=>"Atteikts, PIN dati nepieciešami",
        "309"=>"Status message: unknown file",
        "197"=>"Atteikts, zvaniet AMEX",
        "904"=>"Atteikts, formāta kļūda",
        "113"=>"Atteikts, nepieņemama komisija",
        "198"=>"Atteikts, zvaniet Karšu apstrādes centram",
        "905"=>"Atteikts, pieņēmējbankai nav pieslēguma",
        "114"=>"Atteikts, nav pieprasīts konta tips",
        "906"=>"Atteikts, notiek pārslēgšana",
        "115"=>"Atteikts, pieprasītā funkcija netiek\n  atbalstīta",
        "950"=>"Atteikts, biznesa vienošanās pārkāpums",
        "116"=>"Atteikts, nepietiek līdzekļu",
        "907"=>"Atteikts, nedarbojas izdevējbanka\n  vai pieslēgums",
        "117"=>"Atteikts, nepareizs PIN kods",
        "910"=>"Atteikts, kartes izdevējbankas izslēgta",
        "908"=>"Atteikts, nevar atrast\n  transakcijas adresātu ",
        "118"=>"Atteikts, nav kartes ieraksta",
        "911"=>"Atteikts, kartes izdevējbanka\n  laicīgi nesniedz atbildi",
        "909"=>"Atteikts, sistēmas nepareiza darbība",
        "000"=>"Apstiprināts",
        "120"=>"Atteikts, transakcija nav atļauta\n  terminālam",
        "119"=>"Atteikts, transakcija nav atļauta\n  kartes lietotājam",
        "912"=>"Atteikts, kartes izdevējbankas nav\n  sasniedzama",
        "001"=>"Apstiprināts, ja var apliecināt identitāti",
        "100"=>"Atteikts (Vispārīgs, bez komentāriem)",
        "121"=>"Atteikts, pārsniegts naudas\n  izdošanas limits",
        "913"=>"Atteikts, dubulta pārraide", 
        "002"=>"Apstiprināts par daļēju summu",
        "101"=>"Atteikts, beidzies kartes derīguma termiņš",
        "200"=>"Atņemt karti (Vispārīgs, bez komnetāriem)",
        "122"=>"Atteikts, drošības pārkāpums"
      }
      
      # The homepage URL of the gateway
      self.homepage_url = 'http://www.firstdata.lv/'
      
      # The name of the gateway
      self.display_name = 'FirstData'
      
      def initialize(options = {})
        requires!(options, :pem, :pem_password, :payment)
        @options = options
        @logger  = Logger.new("#{RAILS_ROOT}/log/first_data.log", 2, 1024**2)
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
            'language'      => @options[:locale] || LANGUAGE
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
            'language'      => @options[:locale] || LANGUAGE
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
        raise "No transaction ID" unless @trans_id
        url = get_domain + "/ecomm/ClientHandler?trans_id=#{CGI.escape @trans_id}"
        log :info, url
        url
      end

      private                       

      def test?
        ActiveMerchant::Billing::Base.mode == :test
      end

      def debug?
        ActiveMerchant::Billing::Base.mode == :debug
      end

      def get_domain
        test? ? TEST_DOMAIN : (debug? ? DEBUG_DOMAIN : LIVE_DOMAIN)
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

      # this posts data to FirstData server or to local debug server
      def post url, data, headers = {}
        unless debug?
          ssl_post(url, data, headers)
        else
          connection = Connection.new(url)
          connection.logger = @logger
          connection.request(:post, data, headers)
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
        RESPONSE_CODES[k.to_s] || "Nezināms atbildes kods"
      end

      # log to default logger and if possible to payment logger
      def log severity, message
        @logger.send(severity,message)
        @options[:payment].log(severity,message) if @options[:payment].respond_to?(:log)
      end
    end
  end
end