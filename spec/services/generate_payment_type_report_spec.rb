describe GeneratePaymentTypeReport, type: :service do
  describe '.run_for' do
    context 'with invalid parameter' do
      it 'does not generate' do
        expect(GeneratePaymentTypeReport.run_for(nil)).to be {}
      end
    end

    context 'with valid parameter' do
      let(:event) { FactoryGirl.create :event }
      let(:paid) { FactoryGirl.create(:attendance, event: event, status: :paid) }
      let!(:gateway) { Invoice.from_attendance(paid, Invoice::GATEWAY) }

      it 'generates the hash with the report' do
        result = GeneratePaymentTypeReport.run_for(event)
        expect(result).to eq({ 'gateway' => 400.0 })
      end
    end
  end
end
