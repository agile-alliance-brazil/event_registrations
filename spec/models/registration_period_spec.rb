# encoding: UTF-8
# == Schema Information
#
# Table name: registration_periods
#
#  id             :integer          not null, primary key
#  event_id       :integer
#  title          :string
#  start_at       :datetime
#  end_at         :datetime
#  created_at     :datetime
#  updated_at     :datetime
#  price_cents    :integer          default(0), not null
#  price_currency :string           default("BRL"), not null
#

describe RegistrationPeriod, type: :model do
  before do
    @event = FactoryGirl.create(:event)
    @regular = @event.registration_periods.first

    @super_early_bird = FactoryGirl.create(:registration_period, event: @event, title: 'registration_period.super_early_bird', start_at: Time.zone.local(2013, 01, 01), end_at: Time.zone.local(2013, 01, 31).end_of_day)
    @early_bird = FactoryGirl.create(:registration_period, event: @event, title: 'registration_period.early_bird', start_at: Time.zone.local(2013, 02, 01), end_at: Time.zone.local(2013, 02, 28).end_of_day)

    @regular.start_at = Time.zone.local(2013, 03, 01)
    @regular.end_at = Time.zone.local(2013, 03, 31).end_of_day
    @regular.save

    @late = FactoryGirl.create(:registration_period, event: @event, title: 'registration_period.late', start_at: Time.zone.local(2013, 04, 01), end_at: Time.zone.local(2013, 04, 30).end_of_day)
    @last_minute = FactoryGirl.create(:registration_period, event: @event, title: 'registration_period.last_minute', start_at: Time.zone.local(2013, 05, 01), end_at: Time.zone.local(3013, 05, 31).end_of_day)
  end

  context 'appropriate period' do
    it { expect(RegistrationPeriod.for(@regular.start_at - 1.second).first).to eq(@early_bird) }
    it { expect(RegistrationPeriod.for(@regular.start_at).first).to eq(@regular) }
    it { expect(RegistrationPeriod.for(@regular.start_at + 5).first).to eq(@regular) }
    it { expect(RegistrationPeriod.for(@regular.end_at).first).to eq(@regular) }
    it { expect(RegistrationPeriod.for(@regular.end_at + 1.week).first).to eq(@late) }
  end
end
