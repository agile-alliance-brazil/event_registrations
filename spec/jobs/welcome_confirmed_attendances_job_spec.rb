describe WelcomeConfirmedAttendancesJob, type: :job do
  context 'with active events to advise' do
    let!(:event) { FactoryGirl.create :event, start_date: 1.day.from_now }
    let!(:other_event) { FactoryGirl.create :event, start_date: 1.day.from_now }
    let!(:yesterday_event) { FactoryGirl.create :event, start_date: 1.day.ago }
    let!(:today_event) { FactoryGirl.create :event, start_date: Time.zone.now }
    let!(:past_event) { FactoryGirl.create :event, start_date: 3.days.ago, end_date: 2.days.ago }
    let!(:attendance) { FactoryGirl.create :attendance, event: event, status: :confirmed }
    let!(:other_attendance) { FactoryGirl.create :attendance, event: other_event, status: :confirmed }
    let!(:out) { FactoryGirl.create :attendance, event: other_event, status: :pending }

    it 'calls the queue server twice' do
      mail = stub(deliver_now: true)
      EmailNotifications.expects(:welcome_attendance).twice.returns(mail)
      WelcomeConfirmedAttendancesJob.perform_now
    end
  end
end
