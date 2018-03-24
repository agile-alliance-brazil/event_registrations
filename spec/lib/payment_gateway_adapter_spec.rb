# frozen_string_literal: true

require File.join(File.dirname(__FILE__), '../../lib/payment_gateway_adapter')

describe PaymentGatewayAdapter do
  let(:attendance) { FactoryBot.create(:attendance) }
  let(:invoice) { FactoryBot.create(:invoice, invoiceable: attendance) }

  context 'from invoice' do
    it 'should generate list of items from invoice' do
      items = PaymentGatewayAdapter.from_invoice(invoice, PaymentGatewayAdapter::Item)

      expect(items).to have(1).item
      item = items.first
      expect(item.name).to eq(invoice.name)
      expect(item.number).to eq(invoice.id)
      expect(item.amount).to eq(invoice.amount)
      expect(item.quantity).to eq(1)
    end
  end
end
