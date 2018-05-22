# frozen_string_literal: true

describe PaymentNotification, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :attendance }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :attendance }
  end

  context 'callbacks' do
    describe 'pagseguro payment' do
      before(:each) do
        @attendance = FactoryBot.create(:attendance, registration_date: Time.zone.now, status: :pending)
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
          attendance: @attendance,
          params: @valid_params
        }
      end

      it 'succeed if status is Aprovada and params are valid' do
        FactoryBot.create(:payment_notification, @valid_args)
        expect(@attendance.status).to eq 'paid'
      end

      it "fails if secret doesn't match" do
        @valid_params[:store_code] = 'wrong_secret'
        FactoryBot.create(:payment_notification, @valid_args)
        expect(@attendance).to be_pending
      end

      it 'fails if status is not Aprovada' do
        FactoryBot.create(:payment_notification, @valid_args.merge(status: 'Cancelada'))
        expect(@attendance).to be_pending
      end
    end
  end

  context 'named scope' do
    let(:pagseguro) { FactoryBot.create(:payment_notification, params: { type: 'pag_seguro' }) }

    it { expect(PaymentNotification.pag_seguro).to eq [pagseguro] }
    it { expect(PaymentNotification.completed).to eq [pagseguro] }
  end

  context 'translates params into attributes' do
    before { @attendance = FactoryBot.create(:attendance) }

    it 'from pag_seguro' do
      pag_seguro_params = {
        status: 'Aprovada',
        transaction_code: '1234567890',
        pedido: @attendance.id,
        transaction_inspect: 'bla'
      }

      expected_params = {
        params: pag_seguro_params,
        attendance: @attendance,
        status: 'Aprovada',
        transaction_id: '1234567890',
        notes: 'bla'
      }
      expect(PaymentNotification.send(:from_pag_seguro_params, pag_seguro_params)).to eq expected_params
    end
  end
end
