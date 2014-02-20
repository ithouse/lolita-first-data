require 'spec_helper'

describe LolitaFirstData::Billing do
  let(:transaction){ Fabricate(:transaction) }
  subject(:reservation){ transaction.paymentable }

  describe '#first_data_paid?' do
    context 'with completed transaction' do
      let(:transaction){ Fabricate(:transaction, status: 'completed', transaction_code: '000') }
      it 'be true' do
        expect(reservation.first_data_paid?).to be_true
      end
    end

    context 'with failed transaction' do
      let(:transaction){ Fabricate(:transaction, status: 'failed') }
      it 'be false' do
        expect(reservation.first_data_paid?).to be_false
      end
    end
  end

  describe '#first_data_error_message' do
    context 'without error' do
      let(:transaction){ Fabricate(:transaction, transaction_code: '000') }

      it 'should return nil' do
        expect(reservation.first_data_error_message).to be_nil
      end
    end

    context 'with some error' do
      let(:transaction){ Fabricate(:transaction, transaction_code: '102') }
      it 'should return error message for error code' do
        expect(reservation.first_data_error_message).to eq('Rejected, possible fraud detected')
      end
    end

    context 'with unknown error' do
      let(:transaction){ Fabricate(:transaction, transaction_code: 'zzz') }
      it 'should return unknown error message' do
        expect(reservation.first_data_error_message).to eq('Unknown error')
      end
    end
  end
end
