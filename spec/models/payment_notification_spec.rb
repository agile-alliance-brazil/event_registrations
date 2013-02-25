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
    describe "payment" do
      before(:each) do
        @attendance = FactoryGirl.create(:attendance, :registration_date => Time.zone.local(2013, 5, 1))
        @attendance.should be_pending

        @valid_params = {
          :secret => AppConfig[:paypal][:secret],
          :receiver_email => AppConfig[:paypal][:email],
          :mc_gross => @attendance.registration_fee.to_s,
          :mc_currency => AppConfig[:paypal][:currency]
        }
        @valid_args = {
          :status => "Completed",
          :invoicer => @attendance,
          :params => @valid_params
        }
      end

      it "succeed if status is Completed and params are valid" do
        payment_notification = FactoryGirl.create(:payment_notification, @valid_args)
        @attendance.should be_confirmed
      end

      it "succeed if amount paid in full" do
        payment_notification = FactoryGirl.create(:payment_notification, @valid_args)
        @attendance.should be_confirmed
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
  end

  it "should translate params from paypal into attributes" do
    paypal_params = {
      :payment_status => "Completed",
      :txn_id => "AAABBBCCC",
      :invoice => 2,
      :settle_amount => 10.5,
      :settle_currency => "USD",
      :payer_email => "payer@paypal.com",
      :memo => "Some notes from the buyer",
      :custom => 'Attendance'
    }
    PaymentNotification.from_paypal_params(paypal_params).should == {
      :params => paypal_params,
      :status => "Completed",
      :transaction_id =>  "AAABBBCCC",
      :invoicer_id => 2,
      :invoicer_type => 'Attendance',
      :settle_amount => 10.5,
      :settle_currency => "USD",
      :payer_email => "payer@paypal.com",
      :notes => "Some notes from the buyer"
    }
  end
end
