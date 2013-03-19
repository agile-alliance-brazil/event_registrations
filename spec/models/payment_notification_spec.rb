# encoding: UTF-8
require 'spec_helper'

describe PaymentNotification do
  context "associations" do
    it { should belong_to :invoicer }
  end

  context "validations" do
    should_validate_existence_of :invoicer
  end

  context "callbacks" do
    describe "paypal payment" do
      before(:each) do
        @attendance = FactoryGirl.create(:attendance, registration_date: Time.zone.local(2013, 5, 1))
        @attendance.should be_pending

        @valid_params = {
          type: 'paypal',
          secret: AppConfig[:paypal][:secret],
          receiver_email: AppConfig[:paypal][:email],
          mc_gross: @attendance.registration_fee.to_s,
          mc_currency: AppConfig[:paypal][:currency]
        }
        @valid_args = {
          status: "Completed",
          invoicer: @attendance,
          params: @valid_params
        }
      end

      it "succeed if status is Completed and params are valid" do
        payment_notification = FactoryGirl.create(:payment_notification, @valid_args)
        @attendance.should be_paid
      end

      it "fails if secret doesn't match" do
        @valid_params.merge!(:secret => 'wrong_secret')
        payment_notification = FactoryGirl.create(:payment_notification, @valid_args)
        @attendance.should be_pending
      end

      it "fails if status is not Completed" do
        payment_notification = FactoryGirl.create(:payment_notification, @valid_args.merge(:status => "Failed"))
        @attendance.should be_pending
      end

      it "fails if receiver address doesn't match" do
        @valid_params.merge!(:receiver_email => 'wrong@email.com')
        payment_notification = FactoryGirl.create(:payment_notification, @valid_args)
        @attendance.should be_pending
      end

      it "fails if paid amount doesn't match" do
        @valid_params.merge!(:mc_gross => '1.00')
        payment_notification = FactoryGirl.create(:payment_notification, @valid_args)
        @attendance.should be_pending
      end

      it "fails if currency doesn't match" do
        @valid_params.merge!(:mc_currency => 'GBP')
        payment_notification = FactoryGirl.create(:payment_notification, @valid_args)
        @attendance.should be_pending
      end
    end

    describe "bcash payment" do
      before(:each) do
        @attendance = FactoryGirl.create(:attendance, registration_date: Time.zone.local(2013, 5, 1))
        @attendance.should be_pending

        @valid_params = {
          type: 'bcash',
          secret: AppConfig[:bcash][:secret],
          email_loja: AppConfig[:bcash][:email],
          valor_total: @attendance.registration_fee.to_s,
          cod_status: 1
        }
        @valid_args = {
          status: "Completed",
          invoicer: @attendance,
          params: @valid_params
        }
      end

      it "succeed if status is Completed and params are valid" do
        payment_notification = FactoryGirl.create(:payment_notification, @valid_args)
        @attendance.should be_paid
      end

      it "fails if secret doesn't match" do
        @valid_params.merge!(:secret => 'wrong_secret')
        payment_notification = FactoryGirl.create(:payment_notification, @valid_args)
        @attendance.should be_pending
      end

      it "fails if status is not Completed" do
        payment_notification = FactoryGirl.create(:payment_notification, @valid_args.merge(:status => "Failed"))
        @attendance.should be_pending
      end

      it "fails if receiver address doesn't match" do
        @valid_params.merge!(:email_loja => 'wrong@email.com')
        payment_notification = FactoryGirl.create(:payment_notification, @valid_args)
        @attendance.should be_pending
      end

      it "fails if paid amount doesn't match" do
        @valid_params.merge!(:valor_total => '1.00')
        payment_notification = FactoryGirl.create(:payment_notification, @valid_args)
        @attendance.should be_pending
      end
    end
  end

  it "should translate params from paypal into attributes" do
    paypal_params = {
      payment_status: "Completed",
      txn_id: "AAABBBCCC",
      invoice: 2,
      mc_gross: 10.5,
      mc_currency: "USD",
      receiver_email: "payer@paypal.com",
      memo: "Some notes from the buyer",
      custom: 'Attendance'
    }
    PaymentNotification.from_paypal_params(paypal_params).should == {
      params: paypal_params,
      status: "Completed",
      transaction_id:  "AAABBBCCC",
      invoicer_id: 2,
      notes: "Some notes from the buyer"
    }
  end

  it "should translate params from bcash into attributes" do
    bcash_params = {
      status: "Transação Conluída",
      cod_status: 1,
      id_transacao: "1234567890",
      id_pedido: 2,
      valor_total: 10.5,
      cliente_email: "payer@paypal.com",
      free: 'Attendance'
    }
    PaymentNotification.from_bcash_params(bcash_params).should == {
      params: bcash_params,
      status: "Completed",
      transaction_id:  "1234567890",
      invoicer_id: 2
    }
  end
end
