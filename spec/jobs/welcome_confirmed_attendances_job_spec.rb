# frozen_string_literal: true

describe WelcomeConfirmedAttendancesJob, type: :job do
  context 'with active events to advise' do
    let!(:event) { FactoryBot.create :event, start_date: Time.zone.now }
    let!(:other_event) { FactoryBot.create :event, start_date: Time.zone.now }
    let!(:yesterday_event) { FactoryBot.create :event, start_date: 1.day.ago }
    let!(:today_event) { FactoryBot.create :event, start_date: Time.zone.now }
    let!(:past_event) { FactoryBot.create :event, start_date: 3.days.ago, end_date: 2.days.ago }
    let!(:attendance) { FactoryBot.create :attendance, event: event, status: :confirmed }
    let!(:other_attendance) { FactoryBot.create :attendance, event: other_event, status: :confirmed }
    let!(:out) { FactoryBot.create :attendance, event: other_event, status: :pending }

    it 'calls the queue server twice' do
      mail = stub(deliver_now: true)
      EmailNotifications.expects(:welcome_attendance).twice.returns(mail)
      WelcomeConfirmedAttendancesJob.perform_now
    end
  end
end
