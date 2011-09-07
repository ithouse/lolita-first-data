# encoding: utf-8
require File.dirname(__FILE__) + '/spec_helper'

describe Lolita::FirstData::Transaction do

  let(:trx){ Fabricate(:transaction) }
  let(:gateway) { 
    ActiveMerchant::Billing::FirstDataGateway.new(
      :pem => File.open(File.dirname(__FILE__) + "/cert.pem").read,
      :pem_password => "1234",
      :payment => trx.paymentable
    )
  }
  
  it "should create transaction" do
    trx.transaction_id.should == "D6zNpp/BJnC1y2wZntm4D8XrB2g="
    trx.status.should == :processing
    trx.paymentable.full_price.should == 250
    trx.ip.should == "100.100.100.100"
  end

  it "should process answer" do
    rs = gateway.get_trans_result("127.0.0.1", trx.transaction_id)
    request = double('request')
    request.stub(:env).and_return({})
    trx.process_answer(rs, gateway, request).should be_true
  end
end
