describe RegistrationPeriod, type: :model do
  describe '.for' do
    let(:event) { FactoryGirl.create :event }
    let!(:first_period) { FactoryGirl.create :registration_period, start_at: 2.days.ago, end_at: 1.day.from_now.end_of_day, event: event }
    let!(:second_period) { FactoryGirl.create :registration_period, start_at: 2.days.from_now, end_at: 4.days.from_now.end_of_day, event: event }

    context 'appropriate period' do
      it { expect(RegistrationPeriod.for(Time.zone.yesterday).first).to eq first_period }
      it { expect(RegistrationPeriod.for(Time.zone.today).first).to eq first_period }
      it { expect(RegistrationPeriod.for(Time.zone.tomorrow).first).to eq first_period }
      it { expect(RegistrationPeriod.for(2.days.from_now).first).to eq second_period }
      it { expect(RegistrationPeriod.for(3.days.from_now).first).to eq second_period }
      it { expect(RegistrationPeriod.for(4.days.from_now).first).to eq second_period }
    end
  end
end
