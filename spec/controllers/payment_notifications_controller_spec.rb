# == Schema Information
#
# Table name: payment_notifications
#
#  id              :integer          not null, primary key
#  params          :text(65535)
#  status          :string(255)
#  transaction_id  :string(255)
#  payer_email     :string(255)
#  settle_amount   :decimal(10, )
#  settle_currency :string(255)
#  notes           :text(65535)
#  created_at      :datetime
#  updated_at      :datetime
#  invoice_id      :integer
#
# Indexes
#
#  fk_rails_92030b1506  (invoice_id)
#
# Indexes
#
#  fk_rails_92030b1506  (invoice_id)
#

describe PaymentNotificationsController, type: :controller, block_network: true do
  describe '#create' do
    let(:attendance) { FactoryGirl.create(:attendance) }
    let(:invoice) { FactoryGirl.create(:invoice, invoiceable: attendance) }

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
