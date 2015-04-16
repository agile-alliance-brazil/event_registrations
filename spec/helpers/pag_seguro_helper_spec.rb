describe PagSeguroHelper, type: :helper do
  describe '#add_config_vars' do
    let(:group) { FactoryGirl.create(:registration_group) }
    let(:invoice) { Invoice.from_registration_group(group) }
    subject(:vars) { helper.pag_seguro_variables(invoice, 'return_url', 'notify_url') }

    context 'with a valid invoice' do
      it { expect(vars[:email]).to eq AppConfig[:pag_seguro][:email] }
      it { expect(vars[:token]).to eq AppConfig[:pag_seguro][:token] }
      it { expect(vars[:currency]).to eq 'BRL' }
      it { expect(vars['id_1']).to eq invoice.id }
      it { expect(vars['description_1']).to eq invoice.name }
      it { expect(vars['quantity_1']).to eq 1 }
      it { expect(vars['amount_1']).to eq invoice.amount }
      it { expect(vars[:url_aviso]).to eq('notify_url') }
    end
  end
end