# frozen_string_literal: true

describe QueueService, type: :service do
  describe '.serve_the_queue' do
    context 'with no vacancy' do
      let(:event) { Fabricate :event, attendance_limit: 1 }
      let!(:pending) { Fabricate :attendance, event: event, status: :pending }
      let!(:waiting) { Fabricate :attendance, event: event, status: :waiting }

      before { described_class.serve_the_queue(event) }

      it { expect(waiting.reload.status).to eq 'waiting' }
    end

    context 'with one vacancy' do
      let(:event) { Fabricate :event, attendance_limit: 2 }
      let!(:pending) { Fabricate :attendance, event: event, status: :pending }
      let!(:waiting) { Fabricate :attendance, event: event, status: :waiting }

      before { described_class.serve_the_queue(event) }

      it { expect(waiting.reload.status).to eq 'pending' }
    end

    context 'with more attendances in the queue than vacancies' do
      let(:event) { Fabricate :event, attendance_limit: 3 }
      let!(:pending) { Fabricate :attendance, event: event, status: :pending }
      let!(:first_waiting) { Fabricate :attendance, event: event, status: :waiting, created_at: 1.day.from_now }
      let!(:second_waiting) { Fabricate :attendance, event: event, status: :waiting, created_at: Time.zone.today }
      let!(:third_waiting) { Fabricate :attendance, event: event, status: :waiting, created_at: 2.days.ago }

      it 'dequeues all the attendances and sends the notification' do
        expect(EmailNotificationsMailer).to(receive(:registration_dequeued)).twice.and_call_original
        described_class.serve_the_queue(event)
        expect(third_waiting.reload.status).to eq 'pending'
        expect(second_waiting.reload.status).to eq 'pending'
        expect(first_waiting.reload.status).to eq 'waiting'
      end
    end

    context 'with more vacancies than attendances in the queue' do
      let(:event) { Fabricate :event, attendance_limit: 10 }
      let!(:pending) { Fabricate :attendance, event: event }
      let!(:first_waiting) { Fabricate :attendance, event: event, status: :waiting, created_at: 1.day.from_now }
      let!(:second_waiting) { Fabricate :attendance, event: event, status: :waiting, created_at: Time.zone.today }
      let!(:third_waiting) { Fabricate :attendance, event: event, status: :waiting, created_at: 2.days.ago }

      it 'dequeues all the attendances and sends the notification' do
        expect(EmailNotificationsMailer).to(receive(:registration_dequeued)).exactly(3).times.and_call_original
        described_class.serve_the_queue(event)
        expect(third_waiting.reload.status).to eq 'pending'
        expect(second_waiting.reload.status).to eq 'pending'
        expect(first_waiting.reload.status).to eq 'pending'
      end
    end
  end
end
