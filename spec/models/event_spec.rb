describe Event, type: :model do
  context 'associations' do
    it { is_expected.to have_many :attendances }
    it { is_expected.to have_many :registration_periods }
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
      attendance = FactoryGirl.build(:attendance, event: event)
      event.attendances.expects(:active).returns([attendance])
      expect(event.can_add_attendance?).to be false
    end

    it 'adds more attendance after reaching cancelling attendance' do
      attendance = FactoryGirl.build(:attendance, event: event)
      attendance.cancel
      event.attendances.expects(:active).returns([])
      expect(event.can_add_attendance?).to be true
    end
  end

  describe '#registration_price_for' do
    let(:full_price) { 930.00 }
    let(:event) { FactoryGirl.create(:event, full_price: full_price) }
    let!(:attendance) { FactoryGirl.create :attendance, event: event }
    context 'with one registration period' do
      let(:final_price) { 100 }
      let!(:registration_period) { FactoryGirl.create :registration_period, event: event, start_at: 1.week.ago, end_at: 1.month.from_now }

      subject!(:event_value) { event.registration_price_for(attendance, Invoice::GATEWAY) }
      it { expect(event_value).to eq Money.new(final_price * 100, :BRL) }
    end

    context 'with two registrations periods, one passed and one current' do
      let(:past_price) { 200 }
      let(:final_price) { 100 }
      let!(:registration_period) { FactoryGirl.create :registration_period, event: event, start_at: 1.week.ago, end_at: 1.month.from_now }
      let!(:period_passed) { FactoryGirl.create :registration_period, event: event, start_at: 1.month.ago, end_at: 2.weeks.ago, price: past_price }

      it { expect(event.registration_price_for(attendance, Invoice::GATEWAY)).to eq Money.new(final_price * 100, :BRL) }
    end

    context 'with one registration quota with vacancy and opened' do
      let(:final_price) { 40 }
      let!(:registration_quota) { FactoryGirl.create :registration_quota, event: event, quota: 25 }

      it { expect(event.registration_price_for(attendance, Invoice::GATEWAY)).to eq Money.new(final_price * 100, :BRL) }
    end

    context 'with one registration quota with vacancy and closed' do
      let!(:registration_quota) { FactoryGirl.create :registration_quota, event: event, quota: 25, closed: true }

      it { expect(event.registration_price_for(attendance, Invoice::GATEWAY)).to eq Money.new(event.full_price * 100, :BRL) }
    end

    context 'with one passed period and one registration quota with vacancy and opened' do
      let(:final_price) { 20 }
      let!(:period_passed) { FactoryGirl.create :registration_period, event: event, start_at: 1.month.ago, end_at: 2.weeks.ago }
      let!(:registration_quota) { FactoryGirl.create :registration_quota, event: event, quota: 25, price: final_price }

      it { expect(event.registration_price_for(attendance, Invoice::GATEWAY)).to eq Money.new(final_price * 100, :BRL) }
    end

    context 'with one period and one registration quota with vacancy and opened' do
      let(:final_price) { 100 }
      let!(:registration_period) { FactoryGirl.create :registration_period, event: event, start_at: 1.week.ago, end_at: 1.month.from_now }
      let!(:registration_quota) { FactoryGirl.create :registration_quota, event: event, quota: 25 }

      it { expect(event.registration_price_for(attendance, Invoice::GATEWAY)).to eq Money.new(final_price * 100, :BRL) }
    end

    context 'with one passed period and no quota vacancy' do
      let!(:period_passed) { FactoryGirl.create :registration_period, event: event, start_at: 1.month.ago, end_at: 2.weeks.ago }
      it { expect(event.registration_price_for(attendance, Invoice::GATEWAY)).to eq Money.new(event.full_price * 100, :BRL) }
    end

    context 'and with three quotas, one with limit reached, and other two not' do
      context 'only active attendances' do
        it 'get the next quota, respecting the order' do
          forty_attendances = FactoryGirl.create_list(:attendance, 40, event: event)
          FactoryGirl.create :registration_quota, event: event, attendances: forty_attendances, quota: 25, order: 1

          twenty_five_attendances = FactoryGirl.create_list(:attendance, 25, event: event)
          FactoryGirl.create :registration_quota, event: event, attendances: twenty_five_attendances, quota: 40, order: 3, price: 700
          final_price = 470
          FactoryGirl.create :registration_quota, event: event, quota: 40, order: 2, price: final_price

          expect(event.registration_price_for(attendance, Invoice::GATEWAY)).to eq Money.new(final_price * 100, :BRL)
        end
      end

      context 'only cancelled attendances' do
        it 'get the quote, ignoring the cancelleds' do
          forty_attendances = FactoryGirl.create_list(:attendance, 40, event: event, status: 'cancelled')
          final_price = 360
          FactoryGirl.create :registration_quota, event: event, attendances: forty_attendances, quota: 25, order: 1, price: final_price

          expect(event.registration_price_for(attendance, Invoice::GATEWAY)).to eq Money.new(final_price * 100, :BRL)
        end
      end
    end

    context 'when attendace is member of a registration group' do
      let(:group_30) { FactoryGirl.create :registration_group, event: event, discount: 30 }
      let(:grouped_attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group_30) }
      let(:discounted_value) { full_price * (1.00 - (group_30.discount / 100.00)) }
      let(:discounted_price) { Money.new(discounted_value * 100, :BRL) }

      it { expect(event.registration_price_for(grouped_attendance, Invoice::GATEWAY)).to eq discounted_price }
    end

    context 'when payment type is statement of agreement' do
      subject!(:event_value) { event.registration_price_for(attendance, Invoice::STATEMENT) }
      it { expect(event_value).to eq Money.new(event.full_price * 100, :BRL) }
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

    describe '.not_started' do
      context 'when the event has started' do
        let!(:started) { FactoryGirl.create(:event, start_date: 2.days.ago, end_date: 2.days.from_now) }
        let!(:not_started) { FactoryGirl.create(:event, start_date: 2.days.from_now, end_date: 3.days.from_now) }
        it { expect(Event.not_started).to eq [not_started] }
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

  describe '#started' do
    context 'when the event has started' do
      let(:event) { FactoryGirl.build(:event, start_date: 2.days.ago, end_date: 2.days.from_now) }
      it { expect(event.started).to be_truthy }
    end

    context 'when the event has not started' do
      let(:event) { FactoryGirl.build(:event, start_date: 2.days.from_now, end_date: 3.days.from_now) }
      it { expect(event.started).to be_falsey }
    end
  end
end
