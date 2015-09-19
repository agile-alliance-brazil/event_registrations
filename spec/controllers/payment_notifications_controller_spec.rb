require 'spec_helper'

describe PaymentNotificationsController, type: :controller, block_network: true do
  describe '#create' do
    let(:attendance) { FactoryGirl.create(:attendance) }
    let(:invoice) { FactoryGirl.create(:invoice, attendances: [attendance]) }

    context 'when pagseguro' do
      context 'and the invoice is paid' do
        it 'creates PaymentNotification with pag seguro type' do
          status = PagSeguro::PaymentStatus.new('3')
          transaction = PagSeguro::Transaction.new(status: status)
          PagSeguro::Transaction.expects(:find_by_notification_code).returns transaction
          post :create,
               type: 'pag_seguro', status: 'Aprovada', transacao_id: '12345678',
               pedido: invoice.id, store_code: APP_CONFIG[:pag_seguro][:store_code]
          expect(PaymentNotification.count).to eq 1
          expect(Invoice.last.status).to eq 'paid'
          expect(Attendance.last.status).to eq 'confirmed'
        end
      end

      context 'and the invoice is not paid' do
        it 'creates PaymentNotification with pag seguro type' do
          status = PagSeguro::PaymentStatus.new('7')
          transaction = PagSeguro::Transaction.new(status: status)
          PagSeguro::Transaction.expects(:find_by_notification_code).returns transaction
          post :create,
               type: 'pag_seguro', status: 'Aprovada', transacao_id: '12345678',
               pedido: invoice.id, store_code: APP_CONFIG[:pag_seguro][:store_code]
          expect(PaymentNotification.count).to eq 1
          expect(Invoice.last.status).to eq 'pending'
          expect(Attendance.last.status).to eq 'pending'
        end
      end
    end
  end
end
