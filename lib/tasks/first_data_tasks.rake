require 'fileutils'

namespace :first_data do
  desc "Generate certificates"
  task :generate_certificate do
    fdcg = FirstDataCertGenerator.new
    fdcg.start    
  end
end

class FirstDataCertGenerator

  def initialize
    @cert_type = prompt(%^\nCertificate type?
      1. test
      2. production^) == '2' ? 'production' : 'test'
    @destination = File.join(Rails.root, "config", "first-data", @cert_type)
    FileUtils.mkdir_p(@destination) unless File.exists?(@destination)
    @domain = prompt("Your domain:")
    @merchantId = prompt("Your merchantId:")
  end
  
  def start
    unless File.exists?("#{@destination}/ECOMM.pem")
      gen_cert      
    end
    sign_cert
  end
  
  def gen_cert
    `openssl req -newkey rsa:1024 -keyout #{@destination}/#{@merchantId}_key.pem -out #{@destination}/#{@merchantId}_req.pem -subj "/C=lv/O=#{@domain}/CN=#{@merchantId}" -outform PEM`
    if @cert_type == 'test'
      puts "Open https://secureshop-test.firstdata.lv/report/keystore_.do and enter your email address and copy this into \"Cert Request (PEM)\""      
      puts File.open("#{@destination}/#{@merchantId}_req.pem", 'r').read.split("\n").collect{|line| line unless line =~ /^-/}.join("\n")
    else
      puts "Send \"#{@destination}/#{@merchantId}_req.pem\" to FirstData support email."
    end
    puts "\nAfter receiving email, download all attachments into #{@destination}"
    prompt("To continue press [return]")
  end
  
  def sign_cert
    puts "For PEM pass enter the same as in the first step, for import and export pass type new password."
    `openssl pkcs12 -export -in #{@destination}/#{@merchantId}.pem -out #{@destination}/#{@merchantId}_keystore.p12 -certfile #{@destination}/ECOMM.pem -inkey #{@destination}/#{@merchantId}_key.pem`
    `openssl pkcs12 -in #{@destination}/#{@merchantId}_keystore.p12 > #{@destination}/cert.pem`
    puts "\nNow update your environment configuration files with constants:"
    puts "\nFD_PEM = File.join(Rails.root, \"config\", \"first-data\", \"#{@cert_type}\", \"cert.pem\")"
    puts "FD_PASS = '<Enter PEM pass phrase>'"
    if @cert_type == 'test'
      puts "\nAnd change mode to :test"
      puts %^
    config.after_initialize do
      ActiveMerchant::Billing::Base.mode = :test
    end

    IMPORTANT

    After you have test certificate you should run all FirstData tests https://secureshop-test.firstdata.lv/report/common/testplan/test.jsp
    To do so you need to update your merchant information https://secureshop-test.firstdata.lv/report/merchantlist.do
     - change IP to your current IP
     - change returnOkUrl and returnFailUrl to http://localhost:3000/first_data_test/test
     - save
     
    Now run server and start testing http://localhost:3000/first_data_test/test?nr=1   
    In transaction details you specify all data from response and amount as 1.00 LVL.
      ^
    end
  end
  
  private

  def prompt q
    puts "#{q}"
    $stdout.flush
    $stdin.gets.strip
  end

end