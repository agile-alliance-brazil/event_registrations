# frozen_string_literal: true

RSpec.describe PaymentsController, type: :controller do
  describe '#checkout' do
    let!(:event) { FactoryBot.create :event }

    context 'with valid parameters' do
      let!(:attendance) { FactoryBot.create :attendance, event: event, status: :pending }

      it 'call the register, changes the status and redirect to groups index' do
        PagSeguroService.expects(:checkout).with(attendance, anything).once.returns(url: 'xpto.foo.bar')

        post :checkout, params: { event_id: event.id, id: attendance.id }
        expect(flash[:notice]).to eq I18n.t('payments_controller.checkout.success')
        expect(attendance.reload).to be_pending
        expect(response).to redirect_to 'xpto.foo.bar'
      end
    end

    context 'with errors from service' do
      before(:each) { request.env['HTTP_REFERER'] = event_registration_groups_path(event) }

      let!(:attendance) { FactoryBot.create :attendance, event: event }

      it 'redirects to event with the proper message if any errors' do
        PagSeguroService.expects(:checkout).with(attendance, anything).once.returns(errors: 'xpto')
        post :checkout, params: { event_id: event.id, id: attendance.id }
        expect(flash[:error]).to eq I18n.t('payments_controller.checkout.error', reason: 'xpto')
        expect(response).to redirect_to event_registration_groups_path(event)
      end
    end

    context 'with invalid event' do
      let(:attendance) { FactoryBot.create :attendance }
      before { post :checkout, params: { event_id: 'foo', id: attendance.id } }
      it { expect(response).to have_http_status :not_found }
    end
  end
end
