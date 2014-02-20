# encoding: utf-8
require 'spec_helper'

describe LolitaFirstData::Transaction do

  let(:trx){ Fabricate(:transaction) }
  let(:gateway) { 
    ActiveMerchant::Billing::FirstDataGateway.new(
      :pem => File.open(ENV['FIRST_DATA_PEM']).read,
      :pem_password => ENV['FIRST_DATA_PASS'],
      :payment => trx.paymentable
    )
  }

  it 'should create transaction' do
    expect(Fabricate(:transaction)).to be_valid
  end

  it 'should trigger "first_data_trx_saved" on paymentable' do
    expect(trx.paymentable).to receive(:first_data_trx_saved)
    trx.save
  end

  describe '#process_result' do
    let(:result){ gateway.result(trx.transaction_id, client_ip_addr: '127.0.0.1') }

    it 'updates status to completed' do
      expect_any_instance_of(ActiveMerchant::Billing::FirstDataGateway).to receive(:result).and_return({result: 'OK'})
      expect{ trx.process_result(result) }.to change(trx, :status).to('completed')
    end

    it 'updates status to failed' do
      expect_any_instance_of(ActiveMerchant::Billing::FirstDataGateway).to receive(:result).and_return({result: 'FAILED'})
      expect{ trx.process_result(result) }.to change(trx, :status).to('failed')
    end

    it 'updates transaction code' do
      expect_any_instance_of(ActiveMerchant::Billing::FirstDataGateway).to receive(:result).and_return({result: 'OK', result_code: '000'})
      expect{ trx.process_result(result) }.to change(trx, :transaction_code).to('000')
    end
  end

  context '#return_path' do
    it 'should return return path defined in paymentable' do
      expect(trx.return_path).to eq('/reservation/done')
    end
  end

  context '.first_data_close_business_day' do
    it 'should close day' do
      expect_any_instance_of(ActiveMerchant::Billing::FirstDataGateway).to receive(:close_day).and_return({result: 'OK'})
      Reservation.first_data_close_business_day
    end
  end

  context '#first_data_reverse' do

    context 'with wrong status' do
      it 'should fail to reverse' do
        trx.paymentable.first_data_reverse.should be_nil
        trx.status.should eq('processing')
      end
    end

    context 'with completed status' do
      before do
        trx.update_attribute(:status, 'completed')
      end

      it 'should process reverse' do
        expect_any_instance_of(ActiveMerchant::Billing::FirstDataGateway).to receive(:refund).and_return({result: 'OK'})
        trx.paymentable.first_data_reverse.should be_true
        trx.reload.status.should eq('reversed')
      end
    end
  end
end
