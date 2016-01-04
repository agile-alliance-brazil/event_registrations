require File.join(File.dirname(__FILE__), '../../lib/pag_seguro_adapter')

describe PagSeguroAdapter do
  let(:attendance) { FactoryGirl.create(:attendance) }
  let(:invoice) { FactoryGirl.create(:invoice, invoiceable: attendance) }

  context 'from invoice' do
    it 'generates list of items from invoice' do
      adapter = PagSeguroAdapter.from_invoice(invoice)

      variables = adapter.to_variables
      expect(variables).to have(5).item
      expect(variables['id_1']).to eq(invoice.id)
      expect(variables['description_1']).to eq(invoice.name)
      expect(variables['weight_1']).to eq(0)
      expect(variables['quantity_1']).to eq(1)
      expect(variables['amount_1']).to eq(invoice.amount)
    end
  end
end
