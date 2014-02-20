require "spec_helper"
describe LolitaFirstData::TransactionsController do
  render_views
  let(:reservation){ Fabricate(:reservation) }

  describe "#checkout" do
    context "with paid payment" do
      before do
        session[:payment_data] = {
          billing_class: "Reservation",
          billing_id: reservation.id
        }
        Reservation.any_instance.stub(paid?: true)
      end

      it "should return error" do
        get :checkout, use_route: :lolita_first_data
        expect(response.status).to eq(400)
      end
    end

    context "with unpaid payment" do
      before do
        session[:payment_data] = {
          billing_class: "Reservation",
          billing_id: reservation.id
        }
      end
      context "with success transaction request" do
        it "should redirect to FirstData web" do
          expect_any_instance_of(ActiveMerchant::Billing::FirstDataGateway).to receive(:purchase).with(250, 
                                                                                                       :currency=>"EUR", :client_ip_addr=>"0.0.0.0", :description=>"testing", :language=>"en").and_return({transaction_id: "12345"})
          get :checkout, use_route: :lolita_first_data
          expect(response).to redirect_to("https://secureshop-test.firstdata.lv/ecomm/ClientHandler?trans_id=12345")
        end
      end

      context "with failed transaction request" do
        it "for html format should redirect back" do
          expect_any_instance_of(ActiveMerchant::Billing::FirstDataGateway).to receive(:purchase).and_return({})
          request.env['HTTP_REFERER'] = '/reservation/index'
          get :checkout, use_route: :lolita_first_data
          expect(response).to redirect_to('/reservation/index')
          expect(flash[:error]).to eq('Failed to create a payment, please try again.')
        end

        it "for xhr format should return error" do
          expect_any_instance_of(ActiveMerchant::Billing::FirstDataGateway).to receive(:purchase).and_return({})
          xhr :get, :checkout, use_route: :lolita_first_data
          expect(response.status).to eq(400)
        end
      end
    end
  end

  describe "#answer" do
    let(:reservation){ Fabricate(:reservation) }
    let(:transaction){ Fabricate(:transaction, paymentable: reservation) }

    it "should fail with wrong request" do
      get :answer, use_route: :lolita_first_data
      expect(response.body).to eq("Wrong request")
    end

    it "should successfuly handle transaction" do
      expect_any_instance_of(ActiveMerchant::Billing::FirstDataGateway).to receive(:result).and_return({result: "OK", result_code: "000"})
      get :answer, trans_id: transaction.transaction_id, use_route: :lolita_first_data

      expect(transaction.reload.status).to eq("completed")
      expect(transaction.reload.paymentable.paid?).to be_true
      expect(response).to redirect_to("/reservation/done")
    end
  end
end

