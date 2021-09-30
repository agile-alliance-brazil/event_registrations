# frozen_string_literal: true

RSpec.describe WelcomeConfirmedAttendancesJob, type: :job do
  context 'with active events to welcome attendances' do
    let!(:event) { Fabricate :event, start_date: 4.days.from_now, event_remote: false }
    let!(:other_event) { Fabricate :event, start_date: 4.days.from_now, event_remote: true }
    let!(:yesterday_event) { Fabricate :event, start_date: 1.day.ago }
    let!(:today_event) { Fabricate :event, start_date: Time.zone.now }
    let!(:past_event) { Fabricate :event, start_date: 3.days.ago, end_date: 2.days.ago }
    let(:user) { Fabricate :user, country: 'US' }
    let(:other_user) { Fabricate :user, country: 'US' }
    let!(:attendance) { Fabricate :attendance, event: event, user: user, status: :confirmed }
    let!(:other_attendance) { Fabricate :attendance, event: other_event, user: other_user, status: :confirmed }
    let!(:out) { Fabricate :attendance, event: other_event, status: :pending }

    it 'calls the queue server twice' do
      expect(EmailNotificationsMailer).to(receive(:welcome_attendance)).once.and_call_original
      expect(EmailNotificationsMailer).to(receive(:welcome_attendance_remote_event)).once.and_call_original

      described_class.perform_now
    end
  end
end
