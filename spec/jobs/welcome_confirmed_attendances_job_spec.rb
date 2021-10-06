# frozen_string_literal: true

RSpec.describe WelcomeConfirmedAttendancesJob, type: :job do
  context 'with active events to welcome attendances' do
    it 'calls the queue server twice' do
      travel_to Time.zone.local(2021, 10, 5, 10, 0, 0) do
        event = Fabricate :event, start_date: 4.days.from_now, end_date: 6.days.from_now, event_remote: false
        other_event = Fabricate :event, start_date: 4.days.from_now, end_date: 6.days.from_now, event_remote: true
        Fabricate :event, start_date: 1.day.ago
        Fabricate :event, start_date: Time.zone.now
        Fabricate :event, start_date: 3.days.ago, end_date: 2.days.ago
        user = Fabricate :user, country: 'US', email: 'luciana.mdias@gmail.com'
        other_user = Fabricate :user, country: 'US', email: 'celso.av.martins@gmail.com'
        Fabricate :attendance, event: event, user: user, status: :confirmed
        Fabricate :attendance, event: other_event, user: other_user, status: :confirmed
        Fabricate :attendance, event: other_event, status: :pending

        expect(EmailNotificationsMailer).to(receive(:welcome_attendance)).once.and_call_original
        expect(EmailNotificationsMailer).to(receive(:welcome_attendance_remote_event)).once.and_call_original

        described_class.perform_now
      end
    end
  end
end
