# frozen_string_literal: true

RSpec.describe PaymentsController, type: :controller do
  describe '#checkout' do
    let!(:event) { FactoryBot.create :event }

    context 'with an invoice for group' do
      let!(:group) { FactoryBot.create :registration_group, event: event }
      let(:invoice) { FactoryBot.create :invoice, invoiceable: group }

      it 'call the register, changes the status of invoice and redirect to groups index' do
        PagSeguroService.expects(:checkout).with(invoice, anything).once.returns(url: 'xpto.foo.bar')

        post :checkout, params: { event_id: event.id, id: invoice.id }
        expect(Invoice.last.status).to eq Invoice::SENT
        expect(flash[:notice]).to eq I18n.t('payments_controller.checkout.success')
        expect(response).to redirect_to 'xpto.foo.bar'
      end
    end

    context 'with errors from service' do
      before(:each) { request.env['HTTP_REFERER'] = event_registration_groups_path(event) }

      let!(:group) { FactoryBot.create :registration_group, event: event }
      let(:invoice) { FactoryBot.create :invoice, invoiceable: group }

      it 'redirects to event with the proper message if any errors' do
        PagSeguroService.expects(:checkout).with(invoice, anything).once.returns(errors: 'xpto')
        post :checkout, params: { event_id: event.id, id: invoice.id }
        expect(Invoice.last.status).to eq Invoice::PENDING
        expect(flash[:error]).to eq I18n.t('payments_controller.checkout.error', reason: 'xpto')
        expect(response).to redirect_to event_registration_groups_path(event)
      end
    end

    context 'with invalid event' do
      let(:invoice) { FactoryBot.create :invoice }
      before { post :checkout, params: { event_id: 'foo', id: invoice.id } }
      it { expect(response).to have_http_status :not_found }
    end

    context 'with invalid invoice' do
      before { post :checkout, params: { event_id: event.id, id: 'foo' } }
      it { expect(response).to have_http_status :not_found }
    end
  end
end
