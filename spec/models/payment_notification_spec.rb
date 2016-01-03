# encoding: UTF-8
describe PaymentNotification, type: :model do
  context 'associations' do
    it { should belong_to :invoicer }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :invoicer }
  end

  context 'callbacks' do
    describe 'pagseguro payment' do
      before(:each) do
        @attendance = FactoryGirl.create(:attendance, registration_date: Time.zone.now)
        expect(@attendance).to be_pending

        @valid_params = {
          type: 'pag_seguro',
          secret: APP_CONFIG[:pag_seguro][:token],
          transacao_id: '12345678',
          status: 'Aprovada',
          pedido: @attendance.id,
          store_code: APP_CONFIG[:pag_seguro][:store_code]
        }
        @valid_args = {
          status: 'Completed',
          invoicer: @attendance,
          params: @valid_params
        }
      end

      it 'succeed if status is Aprovada and params are valid' do
        FactoryGirl.create(:payment_notification, @valid_args)
        expect(@attendance).to be_confirmed
      end

      it "fails if secret doesn't match" do
        @valid_params.merge!(store_code: 'wrong_secret')
        FactoryGirl.create(:payment_notification, @valid_args)
        expect(@attendance).to be_pending
      end

      it 'fails if status is not Aprovada' do
        FactoryGirl.create(:payment_notification, @valid_args.merge(status: 'Cancelada'))
        expect(@attendance).to be_pending
      end
    end
  end

  context 'named scope' do
    let(:pagseguro) { FactoryGirl.create(:payment_notification, params: { type: 'pag_seguro' }) }

    it { expect(PaymentNotification.pag_seguro).to eq [pagseguro] }
    it { expect(PaymentNotification.completed).to eq [pagseguro] }
  end

  context 'should translate params into attributes' do
    before { @invoice = FactoryGirl.create(:invoice) }

    it 'from pag_seguro' do
      pag_seguro_params = {
        status: 'Aprovada',
        transaction_code: '1234567890',
        pedido: @invoice.id,
        transaction_inspect: 'bla'
      }

      expected_params = {
        params: pag_seguro_params,
        invoicer: @invoice,
        status: 'Aprovada',
        transaction_id: '1234567890',
        notes: 'bla'
      }
      expect(PaymentNotification.send(:from_pag_seguro_params, pag_seguro_params)).to eq expected_params
    end
  end
end
