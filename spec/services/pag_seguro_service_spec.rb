# frozen_string_literal: true

describe PagSeguroService do
  describe '.checkout' do
    let(:attendance) { FactoryBot.create :attendance }
    context 'with valid parameters' do
      it 'returns an empty hash if no errors' do
        PagSeguro::PaymentRequest.any_instance.expects(:register).once.returns PagSeguro::PaymentRequest::Response.new(nil)
        PagSeguro::PaymentRequest::Response.any_instance.expects(:url).once.returns 'xpto.foo.bar'

        payment = PagSeguro::PaymentRequest.new
        response = PagSeguroService.checkout(attendance, payment)
        expect(payment.items.first.id).to eq attendance.id
        expect(payment.items.first.description).to eq attendance.full_name
        expect(payment.items.first.amount).to eq attendance.registration_value
        expect(payment.items.first.weight).to eq 0
        expect(response).to eq(url: 'xpto.foo.bar')
      end

      it 'returns internal server error when response is nil' do
        PagSeguro::PaymentRequest.any_instance.expects(:register).once.returns
        payment = PagSeguro::PaymentRequest.new
        response = PagSeguroService.checkout(attendance, payment)
        expect(response).to eq(errors: 'Internal server error')
      end
    end

    context 'when errors in response' do
      it 'will answer with the errors' do
        pag_seguro_response = PagSeguro::PaymentRequest::Response.new(nil)
        pag_seguro_response.instance_variable_set(:@errors, %w[bla foo])
        PagSeguro::PaymentRequest.any_instance.expects(:register).returns pag_seguro_response

        payment = PagSeguro::PaymentRequest.new
        response = PagSeguroService.checkout(attendance, payment)
        expect(response).to eq(errors: 'bla\\nfoo')
      end
    end
  end
end
