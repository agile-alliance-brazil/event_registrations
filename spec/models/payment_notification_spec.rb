# encoding: UTF-8
require 'spec_helper'

describe PaymentNotification, type: :model do
  context "associations" do
    it { should belong_to :invoicer }
  end

  context "validations" do
    should_validate_existence_of :invoicer
  end

  context "callbacks" do
    describe "paypal payment" do
      before(:each) do
        event = FactoryGirl.create(:event)
        @attendance = FactoryGirl.create(:attendance, event: event, registration_date: event.registration_periods.first.start_at)
        expect(@attendance).to be_pending
        @attendance.stubs(:registration_value).returns(399)

        @valid_params = {
          type: 'paypal',
          secret: APP_CONFIG[:paypal][:secret],
          receiver_email: APP_CONFIG[:paypal][:email],
          mc_gross: @attendance.registration_value.to_s,
          mc_currency: APP_CONFIG[:paypal][:currency]
        }
        @valid_args = {
          status: "Completed",
          invoicer: @attendance,
          params: @valid_params
        }
      end

      it "succeed if status is Completed and params are valid" do
        payment_notification = FactoryGirl.create(:payment_notification, @valid_args)
        expect(@attendance).to be_paid
      end

      it "fails if secret doesn't match" do
        @valid_params.merge!(secret: 'wrong_secret')
        payment_notification = FactoryGirl.create(:payment_notification, @valid_args)
        expect(@attendance).to be_pending
      end

      it "fails if status is not Completed" do
        payment_notification = FactoryGirl.create(:payment_notification, @valid_args.merge(status: "Failed"))
        expect(@attendance).to be_pending
      end

      it "fails if receiver address doesn't match" do
        @valid_params.merge!(receiver_email: 'wrong@email.com')
        payment_notification = FactoryGirl.create(:payment_notification, @valid_args)
        expect(@attendance).to be_pending
      end

      it "fails if paid amount doesn't match" do
        @valid_params.merge!(mc_gross: '1.00')
        payment_notification = FactoryGirl.create(:payment_notification, @valid_args)
        expect(@attendance).to be_pending
      end

      it "fails if currency doesn't match" do
        @valid_params.merge!(mc_currency: 'GBP')
        payment_notification = FactoryGirl.create(:payment_notification, @valid_args)
        expect(@attendance).to be_pending
      end
    end

    describe "bcash payment" do
      before(:each) do
        @attendance = FactoryGirl.create(:attendance, registration_date: Time.zone.local(2013, 5, 1))
        expect(@attendance).to be_pending

        @valid_params = {
          type: 'bcash',
          secret: APP_CONFIG[:bcash][:secret],
          transacao_id: '12345678',
          status: 'Aprovada',
          pedido: @attendance.id
        }
        @valid_args = {
          status: "Completed",
          invoicer: @attendance,
          params: @valid_params
        }
      end

      it "succeed if status is Aprovada and params are valid" do
        payment_notification = FactoryGirl.create(:payment_notification, @valid_args)
        expect(@attendance).to be_paid
      end

      it "fails if secret doesn't match" do
        @valid_params.merge!(secret: 'wrong_secret')
        payment_notification = FactoryGirl.create(:payment_notification, @valid_args)
        expect(@attendance).to be_pending
      end

      it "fails if status is not Aprovada" do
        payment_notification = FactoryGirl.create(:payment_notification, @valid_args.merge(status: "Cancelada"))
        expect(@attendance).to be_pending
      end
    end
  end

  context "named scope" do
    before do
      @paypal = FactoryGirl.create(:payment_notification, params: {type: 'paypal'})
      @bcash = FactoryGirl.create(:payment_notification, params: {type: 'bcash'})
    end
    it "should scope paypal" do
      expect(PaymentNotification.paypal).to eq([@paypal])
    end
    it "should scope bcash" do
      expect(PaymentNotification.bcash).to eq([@bcash])
    end
    it "should scope completed notifications" do
      @paypal.status = 'Failed'
      @paypal.save
      expect(PaymentNotification.completed).to eq([@bcash])
    end
  end

  context "should translate params into attributes" do
    before do
      @invoice = FactoryGirl.create(:invoice)
    end

    it "from paypal" do
      paypal_params = {
        payment_status: "Completed",
        txn_id: "AAABBBCCC",
        invoice: @invoice.id,
        mc_gross: 10.5,
        mc_currency: "USD",
        receiver_email: "payer@paypal.com",
        memo: "Some notes from the buyer",
        custom: 'Attendance'
      }
      expect(PaymentNotification.from_paypal_params(paypal_params)).to eq({
        params: paypal_params,
        status: "Completed",
        transaction_id:  "AAABBBCCC",
        invoicer: @invoice,
        notes: "Some notes from the buyer"
      })
    end

    it "from bcash" do
      bcash_params = {
        status: "Aprovada",
        transacao_id: "1234567890",
        pedido: @invoice.id
      }
      expect(PaymentNotification.from_bcash_params(bcash_params)).to eq({
        params: bcash_params,
        status: "Completed",
        transaction_id: "1234567890",
        invoicer: @invoice
      })
    end
  end
end
