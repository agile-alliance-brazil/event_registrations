# encoding: UTF-8
require 'spec_helper'
# require 'vcr_setup'

describe PaymentNotificationsController, type: :controller, block_network: true do
  describe '#create' do
    before do
      @invoice = FactoryGirl.create(:invoice)
    end

    it 'creates PaymentNotification with paypal type' do
      expect do
        post :create, type: 'paypal', txn_id: "ABCABC", secret: APP_CONFIG[:paypal][:secret],
                      invoice: @invoice.id, custom: 'Attendance', payment_status: "Completed",
                      receiver_email: APP_CONFIG[:paypal][:email], mc_gross: @invoice.registration_value.to_s,
                      mc_currency: APP_CONFIG[:paypal][:currency]
      end.to change(PaymentNotification, :count).by(1)
    end

    it 'creates PaymentNotification with bcash type' do
      expect do
        post :create, type: 'bcash', status: 'Aprovada', transacao_id: '12345678',
                      pedido: @invoice.id, secret: APP_CONFIG[:bcash][:secret]
      end.to change(PaymentNotification, :count).by(1)
    end

    pending 'creates PaymentNotification with pag_seguro type'
    # it "should create PaymentNotification with pag_seguro type" do
    #   VCR.use_cassette('pag_seguro_notification_paid', :record => :once, :match_requests_on => [:path]) do
    #     expect do
    #       post :create, type: 'pag_seguro', pedido: @invoice.id, :"notificationType" => "transaction",
    #                     :"notificationCode" => "VALID-NOTIFICATION-CODE",
    #                     store_code: APP_CONFIG[:bcash][:store_code]
    #     end.to change(PaymentNotification, :count).by(1)
    #   end
    # end
  end
end
