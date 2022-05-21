# frozen_string_literal: true

RSpec.describe PagseguroAdapter, type: :adapter do
  describe '#read_pag_seguro_body' do
    it 'reads the information in the params' do
      Fabricate :attendance, id: 4, status: :pending, registration_value: 1
      cancelled = Fabricate :attendance, id: 3, status: :pending, registration_value: 1
      Fabricate :attendance, id: 8644, status: :pending, registration_value: 460
      Fabricate :attendance, id: 8677, status: :accepted, registration_value: 460
      Fabricate :attendance, id: 8647, status: :waiting, registration_value: 460
      Fabricate :attendance, id: 8669, status: :cancelled, registration_value: 460
      Fabricate :attendance, id: 8668, status: :confirmed, registration_value: 460
      Fabricate :attendance, id: 8655, status: :paid, registration_value: 460
      paid_less = Fabricate :attendance, id: 8651, status: :pending, registration_value: 470
      no_invoice = Fabricate :attendance, id: 976, status: :pending, registration_value: 470

      response = file_fixture('pag_seguro_invoices_response.json').read

      expect(EmailNotificationsMailer).to(receive(:registration_paid)).exactly(3).times.and_call_original

      described_class.instance.read_pag_seguro_body(JSON.parse(response))

      expect(Invoice.all.count).to eq 9

      expect(cancelled.reload.invoices.map(&:status).uniq).to eq ['cancelled']
      expect(paid_less.reload.invoices.map(&:status).uniq).to eq ['paid']
      expect(paid_less.reload.pending?).to be true
      expect(no_invoice.reload.pending?).to be true

      expect(Attendance.paid.count).to eq 4
    end
  end
end
