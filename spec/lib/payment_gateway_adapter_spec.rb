# frozen_string_literal: true

require File.join(File.dirname(__FILE__), '../../lib/payment_gateway_adapter')

RSpec.describe PaymentGatewayAdapter do
  let(:attendance) { Fabricate(:attendance, payment_type: :gateway) }

  context 'from_attendance' do
    it 'generates a list of items from attendance' do
      items = described_class.from_attendance(attendance, PaymentGatewayAdapter::Item)

      expect(items).to have(1).item
      item = items.first
      expect(item.name).to eq(attendance.full_name)
      expect(item.number).to eq(attendance.id)
      expect(item.amount).to eq(attendance.registration_value)
      expect(item.quantity).to eq(1)
    end
  end
end
