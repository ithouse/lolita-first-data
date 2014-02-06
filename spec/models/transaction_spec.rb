# encoding: utf-8
require "spec_helper"

describe LolitaFirstData::Transaction do

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
    trx.status.should == "processing"
    trx.paymentable.full_price.should == 250
    trx.ip.should == "100.100.100.100"
  end

  it "should process answer and save transaction" do
    rs = gateway.get_trans_result("127.0.0.1", trx.transaction_id)
    request = double("request")
    request.stub(:env).and_return({})
    trx.process_answer(rs, gateway, request).should be_true
  end

  it "should process completed payment" do
    stub_request(:post, "https://secureshop.firstdata.lv:8443/ecomm/MerchantHandler").
      with(:body => {"client_ip_addr"=>"127.0.0.1", "command"=>"c", "trans_id"=>"D6zNpp/BJnC1y2wZntm4D8XrB2g="},
           :headers => {"Accept"=>"*/*", "Content-Type"=>"application/x-www-form-urlencoded", "User-Agent"=>"Ruby"}).
           to_return(:status => 200, :body => "RESULT: OK RESULT_CODE: 000", :headers => {})

    rs = gateway.get_trans_result("127.0.0.1", trx.transaction_id)
    request = double("request")
    request.stub(:env).and_return({})
    trx.process_answer(rs, gateway, request).should be_true
    trx.status.should == "completed"
    trx.paymentable.status.should == "completed"
    trx.paymentable.paid?.should be_true
  end

  it "should process rejected payment" do
    stub_request(:post, "https://secureshop.firstdata.lv:8443/ecomm/MerchantHandler").
      with(:body => {"client_ip_addr"=>"127.0.0.1", "command"=>"c", "trans_id"=>"D6zNpp/BJnC1y2wZntm4D8XrB2g="},
           :headers => {"Accept"=>"*/*", "Content-Type"=>"application/x-www-form-urlencoded", "User-Agent"=>"Ruby"}).
           to_return(:status => 200, :body => "RESULT: FAILED RESULT_CODE: 102", :headers => {})

    rs = gateway.get_trans_result("127.0.0.1", trx.transaction_id)
    request = double("request")
    request.stub(:env).and_return({})
    trx.process_answer(rs, gateway, request).should be_true
    trx.status.should == "rejected"
    trx.transaction_code.should == "102"
    trx.paymentable.status.should == "rejected"
    trx.paymentable.first_data_error_message.should == "Rejected, possible fraud detected"
  end

  context ".first_data_close_business_day" do
    it "should close day" do
      stub_request(:post, "https://secureshop.firstdata.lv:8443/ecomm/MerchantHandler").
        with(:body => {"command"=>"b"},:headers => {"Accept"=>"*/*", "Content-Type"=>"application/x-www-form-urlencoded", "User-Agent"=>"Ruby"}).
        to_return(:status => 200, :body => "RESULT: OK", :headers => {})

      Reservation.first_data_close_business_day.should be_true
    end
  end

  context "#first_data_reverse" do

    context "with wrong status" do
      it "should fail to reverse" do
        trx.paymentable.first_data_reverse.should be_nil
        trx.status.should eq("processing")
      end
    end

    context "with completed status" do
      before do
        stub_request(:post, "https://secureshop.firstdata.lv:8443/ecomm/MerchantHandler").
          with(:body => {"amount"=>"250", "command"=>"r", "trans_id"=>"D6zNpp/BJnC1y2wZntm4D8XrB2g="},
               :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Ruby'}).
               to_return(:status => 200, :body => "RESULT: OK", :headers => {})
        trx.update_attribute(:status, "completed")
      end

      it "should process reverse" do
        trx.paymentable.first_data_reverse.should be_true
        trx.reload.status.should eq("reversed")
      end
    end
  end
end
