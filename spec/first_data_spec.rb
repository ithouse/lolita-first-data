# encoding: utf-8
require File.dirname(__FILE__) + '/spec_helper'

describe Lolita::FirstData::Transaction do

  let(:trx){ Fabricate(:transaction) }
  let(:gateway) { 
    ActiveMerchant::Billing::FirstDataGateway.new(
      :pem => File.open(FD_PEM).read,
      :pem_password => FD_PASS,
      :payment => trx.paymentable
    )
  }

  it "should create transaction" do
    trx.transaction_id.should == "D6zNpp/BJnC1y2wZntm4D8XrB2g="
    trx.status.should == 'processing'
    trx.paymentable.full_price.should == 250
    trx.ip.should == "100.100.100.100"
  end

  it "should process answer and save transaction" do
    rs = gateway.get_trans_result("127.0.0.1", trx.transaction_id)
    request = double('request')
    request.stub(:env).and_return({})
    trx.process_answer(rs, gateway, request).should be_true
  end

  it "should process completed payment" do
    stub_request(:post, "https://secureshop.firstdata.lv:8443/ecomm/MerchantHandler").
    with(:body => {"client_ip_addr"=>"127.0.0.1", "command"=>"c", "trans_id"=>"D6zNpp/BJnC1y2wZntm4D8XrB2g="},
         :headers => {'Accept'=>'*/*', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
    to_return(:status => 200, :body => "RESULT: OK RESULT_CODE: 000", :headers => {})
    
    rs = gateway.get_trans_result("127.0.0.1", trx.transaction_id)
    request = double('request')
    request.stub(:env).and_return({})
    trx.process_answer(rs, gateway, request).should be_true
    trx.status.should == 'completed'
    trx.paymentable.status.should == 'completed'
    trx.paymentable.paid?.should be_true
  end

  it "should process rejected payment" do
    stub_request(:post, "https://secureshop.firstdata.lv:8443/ecomm/MerchantHandler").
    with(:body => {"client_ip_addr"=>"127.0.0.1", "command"=>"c", "trans_id"=>"D6zNpp/BJnC1y2wZntm4D8XrB2g="},
         :headers => {'Accept'=>'*/*', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
    to_return(:status => 200, :body => "RESULT: FAILED RESULT_CODE: 102", :headers => {})
    
    rs = gateway.get_trans_result("127.0.0.1", trx.transaction_id)
    request = double('request')
    request.stub(:env).and_return({})
    trx.process_answer(rs, gateway, request).should be_true
    trx.status.should == 'rejected'
    trx.transaction_code.should == "102"
    trx.paymentable.status.should == 'rejected'
    trx.paymentable.fd_error_message.should == "Rejected, possible fraud detected"
  end

  it "should process close day" do
    stub_request(:post, "https://secureshop.firstdata.lv:8443/ecomm/MerchantHandler").
    with(:body => {"command"=>"b"},:headers => {'Accept'=>'*/*', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
    to_return(:status => 200, :body => "RESULT: OK", :headers => {})

    Reservation.close_business_day.should be_true
  end
end