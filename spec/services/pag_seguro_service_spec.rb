# frozen_string_literal: true

describe PagSeguroService do
  describe '.checkout' do
    let(:attendance) { Fabricate :attendance }

    context 'with valid parameters' do
      it 'returns an empty hash if no errors' do
        expect_any_instance_of(PagSeguro::PaymentRequest).to(receive(:register)).once.and_return(PagSeguro::PaymentRequest::Response.new(nil))
        allow_any_instance_of(PagSeguro::PaymentRequest::Response).to(receive(:url)).and_return('xpto.foo.bar')

        payment = PagSeguro::PaymentRequest.new
        response = described_class.checkout(attendance, payment)
        expect(payment.items.first.id).to eq attendance.id
        expect(payment.items.first.description).to eq attendance.full_name
        expect(payment.items.first.amount).to eq attendance.registration_value
        expect(payment.items.first.weight).to eq 0
        expect(response).to eq(url: 'xpto.foo.bar')
      end

      it 'returns internal server error when response is nil' do
        expect_any_instance_of(PagSeguro::PaymentRequest).to(receive(:register)).once.and_return(nil)
        payment = PagSeguro::PaymentRequest.new
        response = described_class.checkout(attendance, payment)
        expect(response).to eq(errors: 'Internal server error')
      end
    end

    context 'when errors in response' do
      it 'will answer with the errors' do
        pag_seguro_response = PagSeguro::PaymentRequest::Response.new(nil)
        pag_seguro_response.instance_variable_set(:@errors, %w[bla foo])
        expect_any_instance_of(PagSeguro::PaymentRequest).to(receive(:register)).once.and_return(pag_seguro_response)

        payment = PagSeguro::PaymentRequest.new
        response = described_class.checkout(attendance, payment)
        expect(response).to eq(errors: 'bla\\nfoo')
      end
    end
  end
end
