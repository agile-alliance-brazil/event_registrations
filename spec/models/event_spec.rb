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
    let(:event) { Event.create!(name: Faker::Company.name, price_table_link: 'http://localhost:9292/link', full_price: 930.00) }
    let!(:registration_type) { FactoryGirl.create :registration_type, event: event }
    let!(:attendance) { FactoryGirl.create :attendance, event: event }
    context 'with one registration period' do
      let!(:registration_period) { FactoryGirl.create :registration_period, event: event, start_at: 1.week.ago, end_at: 1.month.from_now }
      let!(:price) { RegistrationPrice.create!(registration_type: registration_type, registration_period: registration_period, value: 100.00) }

      it { expect(event.registration_price_for(attendance)).to eq price.value }
    end

    context 'with two registrations periods, one passed and one current' do
      let!(:registration_period) { FactoryGirl.create :registration_period, event: event, start_at: 1.week.ago, end_at: 1.month.from_now }
      let!(:price) { RegistrationPrice.create!(registration_type: registration_type, registration_period: registration_period, value: 100.00) }
      let!(:period_passed) { FactoryGirl.create :registration_period, event: event, start_at: 1.month.ago, end_at: 2.weeks.ago }
      let!(:price_passed) { RegistrationPrice.create!(registration_type: registration_type, registration_period: period_passed, value: 50.00) }

      it { expect(event.registration_price_for(attendance)).to eq price.value }
    end

    context 'with one registration quota with vacancy' do
      let!(:price) { RegistrationPrice.create!(registration_type: registration_type, value: 430.00) }
      let!(:registration_quota) { FactoryGirl.create :registration_quota, event: event, registration_price: price, quota: 25 }

      it { expect(event.registration_price_for(attendance)).to eq price.value }
    end

    context 'with one passed period and one registration quota with vacancy' do
      let!(:period_passed) { FactoryGirl.create :registration_period, event: event, start_at: 1.month.ago, end_at: 2.weeks.ago }
      let!(:price_passed) { RegistrationPrice.create!(registration_type: registration_type, registration_period: period_passed, value: 50.00) }
      let!(:price) { RegistrationPrice.create!(registration_type: registration_type, value: 430.00) }
      let!(:registration_quota) { FactoryGirl.create :registration_quota, event: event, registration_price: price, quota: 25 }

      it { expect(event.registration_price_for(attendance)).to eq price.value }
    end

    context 'with one passed period and one registration quota with vacancy' do
      let!(:registration_period) { FactoryGirl.create :registration_period, event: event, start_at: 1.week.ago, end_at: 1.month.from_now }
      let!(:period_price) { RegistrationPrice.create!(registration_type: registration_type, registration_period: registration_period, value: 100.00) }
      let!(:quota_price) { RegistrationPrice.create!(registration_type: registration_type, value: 430.00) }
      let!(:registration_quota) { FactoryGirl.create :registration_quota, event: event, registration_price: quota_price, quota: 25 }

      it { expect(event.registration_price_for(attendance)).to eq period_price.value }
    end

    context 'with one passed period and no quota' do
      let!(:period_passed) { FactoryGirl.create :registration_period, event: event, start_at: 1.month.ago, end_at: 2.weeks.ago }
      let!(:price_passed) { RegistrationPrice.create!(registration_type: registration_type, registration_period: period_passed, value: 50.00) }

      it { expect(event.registration_price_for(attendance)).to eq event.full_price }
    end

    context 'and with three quotas, one with limit reached, and other two not' do
      it 'get the next quota, respecting the order' do
        no_vacancy_quota_price = RegistrationPrice.create!(registration_type: registration_type, value: 360.00)
        forty_attendances = FactoryGirl.create_list(:attendance, 40, event: event)
        FactoryGirl.create :registration_quota, event: event, registration_price: no_vacancy_quota_price, attendances: forty_attendances, quota: 25, order: 1

        last_quota_price = RegistrationPrice.create!(registration_type: registration_type, value: 700.00)
        twenty_five_attendances = FactoryGirl.create_list(:attendance, 25, event: event)
        FactoryGirl.create :registration_quota, event: event, registration_price: last_quota_price, attendances: twenty_five_attendances, quota: 40, order: 3

        medium_quota_price = RegistrationPrice.create!(registration_type: registration_type, value: 470.00)
        FactoryGirl.create :registration_quota, event: event, registration_price: medium_quota_price, quota: 40, order: 2

        expect(event.registration_price_for(attendance)).to eq 470.00
      end
    end

    context 'when attendace is member of a registration group' do
      let(:group_30) { FactoryGirl.create :registration_group, event: event, discount: 30 }
      let(:grouped_attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group_30) }

      it { expect(event.registration_price_for(grouped_attendance)).to eq 930 * (1.00 - (group_30.discount / 100.00)) }
    end
  end

  describe '#free?' do
    let(:event) { FactoryGirl.build(:event) }
    context 'with a non free registration' do
      let!(:registration_type) { FactoryGirl.create :registration_type, event: event }
      let(:attendance) { FactoryGirl.build(:attendance, event: event, registration_type: registration_type) }
      it { expect(event.free?(attendance)).to be_falsey }
    end

    context 'with a non free registration' do
      let!(:registration_type) { FactoryGirl.create :registration_type, event: event, title: 'bla-xpto' }
      let(:attendance) { FactoryGirl.build(:attendance, event: event, registration_type: registration_type) }
      it { expect(event.free?(attendance)).to be_truthy }
    end
  end
end
