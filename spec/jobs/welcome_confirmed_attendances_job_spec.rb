# frozen_string_literal: true

describe WelcomeConfirmedAttendancesJob, type: :job do
  context 'with active events to advise' do
    let!(:event) { Fabricate :event, start_date: Time.zone.now }
    let!(:other_event) { Fabricate :event, start_date: Time.zone.now }
    let!(:yesterday_event) { Fabricate :event, start_date: 1.day.ago }
    let!(:today_event) { Fabricate :event, start_date: Time.zone.now }
    let!(:past_event) { Fabricate :event, start_date: 3.days.ago, end_date: 2.days.ago }
    let!(:attendance) { Fabricate :attendance, event: event, status: :confirmed }
    let!(:other_attendance) { Fabricate :attendance, event: other_event, status: :confirmed }
    let!(:out) { Fabricate :attendance, event: other_event, status: :pending }

    it 'calls the queue server twice' do
      expect(EmailNotificationsMailer).to(receive(:welcome_attendance)).twice.and_call_original
      described_class.perform_now
    end
  end
end
