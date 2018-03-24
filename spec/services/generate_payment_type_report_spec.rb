# frozen_string_literal: true

describe GeneratePaymentTypeReport, type: :service do
  let(:event) { FactoryBot.create :event }
  describe '.run_for' do
    context 'with invalid parameter' do
      it 'does not generate' do
        expect(GeneratePaymentTypeReport.run_for(nil)).to eq({})
      end
    end

    context 'with valid parameter' do
      let!(:paid) { FactoryBot.create(:attendance, event: event, status: :paid, payment_type: 'gateway') }

      it 'generates the hash with the report' do
        result = GeneratePaymentTypeReport.run_for(event)
        expect(result).to eq(['gateway', 400] => 1)
      end
    end
  end
end
