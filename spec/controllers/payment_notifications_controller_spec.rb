# encoding: UTF-8
require 'spec_helper'

describe PaymentNotificationsController do
  describe "POST create" do
    before do
      @attendance = FactoryGirl.create(:attendance)
    end

    it "should create PaymentNotification with paypal type" do
      lambda {
        post :create, type: 'paypal', txn_id: "ABCABC", secret: AppConfig[:paypal][:secret],
                      invoice: @attendance.id, custom: 'Attendance', payment_status: "Completed",
                      receiver_email: AppConfig[:paypal][:email], mc_gross: @attendance.registration_fee.to_s,
                      mc_currency: AppConfig[:paypal][:currency]
      }.should change(PaymentNotification, :count).by(1)
    end

    it "should create PaymentNotification with bcash type" do
      lambda {
        post :create, type: 'bcash', status: "Transação Conluída", cod_status: 1, id_transacao: "ABCABC",
                      id_pedido: @attendance.id, valor_total: @attendance.registration_fee.to_s,
                      email_loja: AppConfig[:bcash][:email], free: 'Attendance', secret: AppConfig[:bcash][:secret]
      }.should change(PaymentNotification, :count).by(1)
    end
  end
end
