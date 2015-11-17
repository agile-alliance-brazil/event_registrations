# == Schema Information
#
# Table name: events
#
#  id                :integer          not null, primary key
#  name              :string
#  location_and_date :string
#  created_at        :datetime
#  updated_at        :datetime
#  price_table_link  :string
#  allow_voting      :boolean
#  attendance_limit  :integer
#  full_price        :decimal(, )
#  start_date        :datetime
#  end_date          :datetime
#  characteristic    :string
#

describe Event, type: :model do
  context 'associations' do
    it { should have_many :attendances }
    it { should have_many :registration_periods }
    it { should have_many :registration_types }
  end

  describe '#attendance limit' do
    let(:event) { FactoryGirl.build(:event) }
    before { event.attendance_limit = 1 }

    it 'adds more attendance without limit' do
      event.attendance_limit = nil
      expect(event.can_add_attendance?).to be true
    end

    it 'adds more attendance with 0 limit' do
      event.attendance_limit = 0
      expect(event.can_add_attendance?).to be true
    end

    it { expect(event.can_add_attendance?).to be true }

    it 'not adds more attendance after reaching limit' do
      attendance = FactoryGirl.build(:attendance, :event => event)
      event.attendances.expects(:active).returns([attendance])
      expect(event.can_add_attendance?).to be false
    end

    it 'adds more attendance after reaching cancelling attendance' do
      attendance = FactoryGirl.build(:attendance, :event => event)
      attendance.cancel
      event.attendances.expects(:active).returns([])
      expect(event.can_add_attendance?).to be true
    end
  end

  describe '#registration_price_for' do
    let(:event) { FactoryGirl.create(:event, full_price: 930.00) }
    let!(:registration_type) { FactoryGirl.create :registration_type, event: event }
    let!(:attendance) { FactoryGirl.create :attendance, event: event }
    context 'with one registration period' do
      let!(:registration_period) { FactoryGirl.create :registration_period, event: event, start_at: 1.week.ago, end_at: 1.month.from_now }
      let!(:price) { RegistrationPrice.create!(registration_type: registration_type, registration_period: registration_period, value: 100.00) }

      subject!(:event_value) { event.registration_price_for(attendance, Invoice::GATEWAY) }
      it { expect(event_value).to eq price.value }
    end

    context 'with two registrations periods, one passed and one current' do
      let!(:registration_period) { FactoryGirl.create :registration_period, event: event, start_at: 1.week.ago, end_at: 1.month.from_now }
      let!(:price) { RegistrationPrice.create!(registration_type: registration_type, registration_period: registration_period, value: 100.00) }
      let!(:period_passed) { FactoryGirl.create :registration_period, event: event, start_at: 1.month.ago, end_at: 2.weeks.ago }
      let!(:price_passed) { RegistrationPrice.create!(registration_type: registration_type, registration_period: period_passed, value: 50.00) }

      it { expect(event.registration_price_for(attendance, Invoice::GATEWAY)).to eq price.value }
    end

    context 'with one registration quota with vacancy and opened' do
      let!(:price) { RegistrationPrice.create!(registration_type: registration_type, value: 430.00) }
      let!(:registration_quota) { FactoryGirl.create :registration_quota, event: event, registration_price: price, quota: 25 }

      it { expect(event.registration_price_for(attendance, Invoice::GATEWAY)).to eq price.value }
    end

    context 'with one registration quota with vacancy and closed' do
      let!(:price) { RegistrationPrice.create!(registration_type: registration_type, value: 430.00) }
      let!(:registration_quota) { FactoryGirl.create :registration_quota, event: event, registration_price: price, quota: 25, closed: true }

      it { expect(event.registration_price_for(attendance, Invoice::GATEWAY)).to eq event.full_price }
    end

    context 'with one passed period and one registration quota with vacancy and opened' do
      let!(:period_passed) { FactoryGirl.create :registration_period, event: event, start_at: 1.month.ago, end_at: 2.weeks.ago }
      let!(:price_passed) { RegistrationPrice.create!(registration_type: registration_type, registration_period: period_passed, value: 50.00) }
      let!(:price) { RegistrationPrice.create!(registration_type: registration_type, value: 430.00) }
      let!(:registration_quota) { FactoryGirl.create :registration_quota, event: event, registration_price: price, quota: 25 }

      it { expect(event.registration_price_for(attendance, Invoice::GATEWAY)).to eq price.value }
    end

    context 'with one period and one registration quota with vacancy and opened' do
      let!(:registration_period) { FactoryGirl.create :registration_period, event: event, start_at: 1.week.ago, end_at: 1.month.from_now }
      let!(:period_price) { RegistrationPrice.create!(registration_type: registration_type, registration_period: registration_period, value: 100.00) }
      let!(:quota_price) { RegistrationPrice.create!(registration_type: registration_type, value: 430.00) }
      let!(:registration_quota) { FactoryGirl.create :registration_quota, event: event, registration_price: quota_price, quota: 25 }

      it { expect(event.registration_price_for(attendance, Invoice::GATEWAY)).to eq period_price.value }
    end

    context 'with one passed period and no quota vacancy' do
      let!(:period_passed) { FactoryGirl.create :registration_period, event: event, start_at: 1.month.ago, end_at: 2.weeks.ago }
      let!(:price_passed) { RegistrationPrice.create!(registration_type: registration_type, registration_period: period_passed, value: 50.00) }

      it { expect(event.registration_price_for(attendance, Invoice::GATEWAY)).to eq event.full_price }
    end

    context 'and with three quotas, one with limit reached, and other two not' do
      context 'only active attendances' do
        it 'get the next quota, respecting the order' do
          no_vacancy_quota_price = RegistrationPrice.create!(registration_type: registration_type, value: 360.00)
          forty_attendances = FactoryGirl.create_list(:attendance, 40, event: event)
          FactoryGirl.create :registration_quota, event: event, registration_price: no_vacancy_quota_price, attendances: forty_attendances, quota: 25, order: 1

          last_quota_price = RegistrationPrice.create!(registration_type: registration_type, value: 700.00)
          twenty_five_attendances = FactoryGirl.create_list(:attendance, 25, event: event)
          FactoryGirl.create :registration_quota, event: event, registration_price: last_quota_price, attendances: twenty_five_attendances, quota: 40, order: 3

          medium_quota_price = RegistrationPrice.create!(registration_type: registration_type, value: 470.00)
          FactoryGirl.create :registration_quota, event: event, registration_price: medium_quota_price, quota: 40, order: 2

          expect(event.registration_price_for(attendance, Invoice::GATEWAY)).to eq 470.00
        end
      end

      context 'only cancelled attendances' do
        it 'get the quote, ignoring the cancelleds' do
          vacancy_quota_price = RegistrationPrice.create!(registration_type: registration_type, value: 360.00)
          forty_attendances = FactoryGirl.create_list(:attendance, 40, event: event, status: 'cancelled')
          FactoryGirl.create :registration_quota, event: event, registration_price: vacancy_quota_price, attendances: forty_attendances, quota: 25, order: 1

          expect(event.registration_price_for(attendance, Invoice::GATEWAY)).to eq 360.00
        end
      end
    end

    context 'when attendace is member of a registration group' do
      let(:group_30) { FactoryGirl.create :registration_group, event: event, discount: 30 }
      let(:grouped_attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group_30) }

      it { expect(event.registration_price_for(grouped_attendance, Invoice::GATEWAY)).to eq 930 * (1.00 - (group_30.discount / 100.00)) }
    end

    context 'when payment type is statement of agreement' do
      subject!(:event_value) { event.registration_price_for(attendance, Invoice::STATEMENT) }
      it { expect(event_value).to eq 930 }
    end
  end

  describe '#free?' do
    let(:event) { FactoryGirl.build(:event) }
    context 'with a non free registration' do
      let!(:registration_type) { FactoryGirl.create :registration_type, event: event }
      let(:attendance) { FactoryGirl.build(:attendance, event: event, registration_type: registration_type) }
      it { expect(event.free?(attendance)).to be_falsey }
    end

    context 'with a free registration' do
      let!(:registration_type) { FactoryGirl.create :registration_type, event: event, title: 'bla-xpto' }
      let(:attendance) { FactoryGirl.build(:attendance, event: event, registration_type: registration_type) }
      it { expect(event.free?(attendance)).to be_truthy }
    end
  end

  context 'scopes' do
    describe '.active_for' do
      context 'with one event available and other with end date at past year' do
        let!(:event) { FactoryGirl.create :event, start_date: Time.zone.yesterday, end_date: Time.zone.tomorrow }
        let!(:other_event) { FactoryGirl.create :event, start_date: 1.year.ago, end_date: 1.year.ago }
        it { expect(Event.active_for(Time.zone.today)).to match_array [event] }
      end

      context 'with two events available and other with end date at past year' do
        let!(:event) { FactoryGirl.create :event, start_date: Time.zone.yesterday, end_date: Time.zone.tomorrow }
        let!(:other_event_valid) { FactoryGirl.create :event, start_date: Time.zone.yesterday, end_date: Time.zone.tomorrow }
        let!(:other_event) { FactoryGirl.create :event, start_date: 1.year.ago, end_date: 1.year.ago }
        it { expect(Event.active_for(Time.zone.today)).to match_array [event, other_event_valid] }
      end
    end

    describe '.ended' do
      context 'and one at the right period and other not' do
        let!(:event) { FactoryGirl.create(:event, start_date: 3.months.ago, end_date: 2.months.ago) }
        let!(:out) { FactoryGirl.create(:event, start_date: 1.day.ago, end_date: 1.year.from_now) }

        it { expect(Event.ended).to eq [event] }
      end
    end
  end

  describe '#period_for' do
    let(:event) { FactoryGirl.build(:event) }
    context 'with one period' do
      let!(:registration_period) { FactoryGirl.create :registration_period, event: event, start_at: 1.week.ago, end_at: 1.month.from_now }
      it { expect(event.period_for).to eq registration_period }
    end

    context 'with no period' do
      it { expect(event.period_for).to eq nil }
    end
  end

  describe '#find_quota' do
    let(:event) { FactoryGirl.build(:event) }
    context 'with one quota' do
      let!(:registration_quota) { FactoryGirl.create :registration_quota, event: event, quota: 25 }
      it { expect(event.find_quota.first).to eq registration_quota }
    end

    context 'with no quota' do
      it { expect(event.find_quota).to eq [] }
    end
  end
end
