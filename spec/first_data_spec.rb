# encoding: utf-8
require File.dirname(__FILE__) + '/spec_helper'

describe Lolita::FirstData::Transaction do
  it "should create transaction" do
    r = Reservation.create
    trx = Lolita::FirstData::Transaction.create!(
      :transaction_id => "D6zNpp/BJnC1y2wZntm4D8XrB2g=",
      :status => :processing,
      :paymentable_id => r.id,
      :paymentable_type => r.class.to_s,
      :ip => "100.100.100.100"
    )
    trx.transaction_id.should == "D6zNpp/BJnC1y2wZntm4D8XrB2g="
    trx.status.should == :processing
    trx.paymentable.should == r
    trx.ip.should == "100.100.100.100"
  end

end
