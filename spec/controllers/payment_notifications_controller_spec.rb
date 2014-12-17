# encoding: UTF-8
require 'spec_helper'

describe PaymentNotificationsController, type: :controller do
  describe "POST create" do
    before do
      @attendance = FactoryGirl.create(:attendance)
      Attendance.any_instance.stubs(:registration_fee).returns(399)
    end

    it "should create PaymentNotification with paypal type" do
      expect{
        post :create, type: 'paypal', txn_id: "ABCABC", secret: AppConfig[:paypal][:secret],
                      invoice: @attendance.id, custom: 'Attendance', payment_status: "Completed",
                      receiver_email: AppConfig[:paypal][:email], mc_gross: @attendance.registration_fee.to_s,
                      mc_currency: AppConfig[:paypal][:currency]
      }.to change(PaymentNotification, :count).by(1)
    end

    it "should create PaymentNotification with bcash type" do
      expect{
        post :create, type: 'bcash', status: "Aprovada", transacao_id: "12345678",
                      pedido: @attendance.id, secret: AppConfig[:bcash][:secret]
      }.to change(PaymentNotification, :count).by(1)
    end
  end
end
