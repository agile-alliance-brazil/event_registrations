# frozen_string_literal: true

require File.join(File.dirname(__FILE__), '../../lib/pag_seguro_adapter')

describe PagSeguroAdapter do
  let(:attendance) { FactoryBot.create(:attendance) }

  it 'generates list of items from attendance' do
    adapter = PagSeguroAdapter.from_attendance(attendance)

    variables = adapter.to_variables
    expect(variables).to have(5).item
    expect(variables['id_1']).to eq(attendance.id)
    expect(variables['description_1']).to eq(attendance.full_name)
    expect(variables['weight_1']).to eq(0)
    expect(variables['quantity_1']).to eq(1)
    expect(variables['amount_1']).to eq(attendance.registration_value)
  end
end
