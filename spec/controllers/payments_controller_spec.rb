describe PaymentsController, type: :controller do

  describe '#checkout' do
    let!(:event) { FactoryGirl.create :event }
    context 'with an invoice for group' do
      let!(:group) { FactoryGirl.create :registration_group, event: event }
      let(:invoice) { FactoryGirl.create :invoice, registration_group: group }
      it 'call the register, changes the status of invoice and redirect to groups index' do
        PagSeguroService.expects(:checkout).with(invoice, anything).once.returns( {} )
        post :checkout, event_id: event.id, id: invoice.id
        expect(Invoice.last.status).to eq Invoice::SENT
        expect(response).to redirect_to event_registration_groups_path(event)
        expect(flash[:notice]).to eq 'Payment sent'
      end
    end

    context 'with errors from service' do
      let!(:group) { FactoryGirl.create :registration_group, event: event }
      let(:invoice) { FactoryGirl.create :invoice, registration_group: group }
      it 'redirects to event with the proper message if any errors' do
        PagSeguroService.expects(:checkout).with(invoice, anything).once.returns( { errors: 'xpto' } )
        post :checkout, event_id: event.id, id: invoice.id
        expect(Invoice.last.status).to eq Invoice::PENDING
        expect(response).to redirect_to event_registration_groups_path(event)
        expect(flash[:alert]).to eq 'xpto'
      end
    end
  end
end
