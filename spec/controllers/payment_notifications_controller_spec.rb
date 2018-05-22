# frozen_string_literal: true

RSpec.describe PaymentNotificationsController, type: :controller do
  before { WebMock.enable! }
  after { WebMock.disable! }

  describe 'POST #create' do
    let(:attendance) { FactoryBot.create(:attendance, status: :pending) }

    context 'when pagseguro' do
      context 'with a valid status' do
        it 'creates PaymentNotification with pag seguro type' do
          status = PagSeguro::PaymentStatus.new('3')
          transaction = PagSeguro::Transaction.new(status: status)
          PagSeguro::Transaction.expects(:find_by_notification_code).returns transaction
          post :create, params: { type: 'pag_seguro', status: 'Aprovada', transacao_id: '12345678', pedido: attendance.id, store_code: APP_CONFIG[:pag_seguro][:store_code] }
          expect(PaymentNotification.count).to eq 1
          expect(Attendance.last.status).to eq 'paid'
        end
      end
    end

    context 'with a null status' do
      it 'creates PaymentNotification with pag seguro type' do
        transaction = PagSeguro::Transaction.new(status: '0')
        PagSeguro::Transaction.expects(:find_by_notification_code).returns transaction
        PagSeguro::Transaction.any_instance.expects(:status).returns nil
        post :create, params: { type: 'pag_seguro', status: 'Aprovada', transacao_id: '12345678', pedido: attendance.id, store_code: APP_CONFIG[:pag_seguro][:store_code] }
        expect(PaymentNotification.count).to eq 0
        expect(Attendance.last.status).to eq 'pending'
      end
    end
  end
end
