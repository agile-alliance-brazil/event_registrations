describe PagSeguroService do
  describe '.checkout' do
    context 'with a valid invoice' do
      let(:invoice) { FactoryGirl.create :invoice }
      it 'returns an empty hash if no errors' do
        PagSeguro::PaymentRequest.any_instance.expects(:register).once.returns PagSeguro::PaymentRequest::Response.new(nil)
        payment = PagSeguro::PaymentRequest.new
        response = PagSeguroService.checkout(invoice, payment)
        expect(payment.items.first.id).to eq invoice.id
        expect(payment.items.first.description).to eq invoice.name
        expect(payment.items.first.amount).to eq invoice.amount
        expect(payment.items.first.weight).to eq 0
        expect(response).to eq({})
      end

      it 'returns internal server error when response is nil' do
        PagSeguro::PaymentRequest.any_instance.expects(:register).once.returns
        payment = PagSeguro::PaymentRequest.new
        response = PagSeguroService.checkout(invoice, payment)
        expect(response).to eq({ errors: 'Internal server error' })
      end
    end

    pending 'when errors in response'
  end
end
