# frozen_string_literal: true

RSpec.describe Invoice, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :attendance }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :status }
    it { is_expected.to validate_presence_of :payment_type }
    it { is_expected.to validate_presence_of :settle_amount }
    it { is_expected.to validate_presence_of :transaction_id }
  end

  describe '#paid?' do
    it 'returns true when the status is valid and the values are the same' do
      first_attendance = Fabricate :attendance, registration_value: 100
      first_invoice = Fabricate :invoice, attendance: first_attendance, settle_amount: 100, status: :paid
      second_invoice = Fabricate :invoice, attendance: first_attendance, settle_amount: 50, status: :paid
      third_invoice = Fabricate :invoice, attendance: first_attendance, settle_amount: 120, status: :available
      fourth_invoice = Fabricate :invoice, attendance: first_attendance, settle_amount: 120, status: :cancelled
      fifth_invoice = Fabricate :invoice, attendance: first_attendance, settle_amount: 120, status: :financial_dispute
      sixth_invoice = Fabricate :invoice, attendance: first_attendance, settle_amount: 120, status: :value_returned

      expect(first_invoice.paid?).to be true
      expect(second_invoice.paid?).to be false
      expect(third_invoice.paid?).to be true
      expect(fourth_invoice.paid?).to be false
      expect(fifth_invoice.paid?).to be false
      expect(sixth_invoice.paid?).to be false
    end
  end
end
