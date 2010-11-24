require 'fileutils'

namespace :first_data do
  desc "Generate certificates"
  task :generate_certificate do
    fdcg = FirstDataCertGenerator.new
    fdcg.gen_cert
    fdcg.sign_cert
  end
end

class FirstDataCertGenerator

  def initialize
    @cert_type = prompt(%^\nCertificate type?
      1. test
      2. production^) == '2' ? 'production' : 'test'
    @destination = File.join(RAILS_ROOT, "config", "first_data", @cert_type)
    FileUtils.mkdir_p(destination) unless File.exists?(@destination)
    @domain = prompt("Your domain:")
    @merchantId = prompt("Your merchantId:")
  end
  
  def gen_cert
    `openssl req -newkey rsa:1024 -keyout #{@destination}/#{@merchantId}_key.pem -out #{@destination}/#{@merchantId}_req.pem -subj "/C=lv/O=#{@domain}/CN=#{@merchantId}" -outform PEM`
    if @cert_type == 'test'
      puts "Open https://secureshop-test.firstdata.lv/report/keystore_.do and enter your email address and copy this into \"Cert Request (PEM)\""      
    else
      puts "Send this to FirstData support email:"
    end
    puts File.open("#{@destination}/#{@merchantId}_req.pem", 'r').read.split("\n").collect{|line| line unless line =~ /^-/}.join("\n")
    puts "\nAfter this you will recieve email, download all attachments into #{@destination}"
    prompt("To continue press [return]")
  end
  
  def sign_cert
    `openssl pkcs12 -export -in #{@destination}/#{@merchantId}.pem -out #{@destination}/#{@merchantId}_keystore.p12 -certfile #{@destination}/ECOMM.pem -inkey #{@destination}/#{@merchantId}_key.pem`
    `openssl pkcs12 -in #{@destination}/#{@merchantId}_keystore.p12 > #{@destination}/cert.pem`
    puts "\nNow update your environment configuration files with constants:"
    puts "\n\tFIRSTDATA_PEM = File.join(RAILS_ROOT, \"config\", \"first_data\", \"#{@cert_type}\", \"cert.pem\")"
    puts "\tFIRSTDATA_PASS = '<Enter PEM pass phrase>'"
    if @cert_type == 'test'
      puts "\nAnd change mode to :test"
      puts %^
    config.after_initialize do
      ActiveMerchant::Billing::Base.mode = :test
    end
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