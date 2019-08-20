# frozen_string_literal: true

RSpec.describe Event, type: :model do
  context 'associations' do
    it { is_expected.to have_many :attendances }
    it { is_expected.to have_many :registration_periods }
    it { is_expected.to have_and_belong_to_many(:organizers).class_name('User') }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :full_price }
    it { is_expected.to validate_presence_of :start_date }
    it { is_expected.to validate_presence_of :end_date }
    it { is_expected.to validate_presence_of :main_email_contact }
    it { is_expected.to validate_presence_of :state }
    it { is_expected.to validate_presence_of :country }
    it { is_expected.to validate_presence_of :city }

    context 'with start date before end date' do
      let(:event) { FactoryBot.build :event, start_date: Date.new(2016, 5, 20).in_time_zone, end_date: Date.new(2016, 5, 21).in_time_zone }
      it { expect(event.valid?).to be_truthy }
    end

    context 'with end date before start date' do
      let(:event) { FactoryBot.build :event, start_date: Date.new(2016, 5, 21).in_time_zone, end_date: Date.new(2016, 5, 20).in_time_zone }
      it { expect(event.valid?).to be_falsey }
    end

    context 'with start date equal to end date' do
      let(:event) { FactoryBot.build :event, start_date: Date.new(2016, 5, 20).in_time_zone, end_date: Date.new(2016, 5, 20).in_time_zone }
      it { expect(event.valid?).to be_truthy }
    end
  end

  describe '#full?' do
    context 'with a defined event limit' do
      let(:event) { FactoryBot.create(:event, attendance_limit: 1) }
      context 'and it was not reached' do
        it { expect(event.full?).to be_falsey }
      end
      context 'and it was reached' do
        let!(:attendance) { FactoryBot.create(:attendance, event: event, status: :pending) }
        it { expect(event.full?).to be_truthy }
      end
      context 'and it was reached by a cancelled attendance' do
        let(:attendance) { FactoryBot.create(:attendance, event: event, status: :cancelled) }
        it { expect(event.full?).to be_falsey }
      end

      context 'and the event has reserved places in groups' do
        let(:event) { FactoryBot.create(:event, attendance_limit: 10) }

        context 'and is full' do
          let!(:group) { FactoryBot.create :registration_group, event: event, paid_in_advance: true, capacity: 5, amount: 100 }
          let!(:other_group) { FactoryBot.create :registration_group, event: event, paid_in_advance: true, capacity: 5, amount: 100 }
          it { expect(event.full?).to be_truthy }
        end

        context 'and is not full' do
          let!(:group) { FactoryBot.create :registration_group, event: event, paid_in_advance: true, capacity: 5, amount: 100 }
          it { expect(event.full?).to be_falsey }
        end
      end
    end

    context 'with a zero event limit' do
      let(:event) { FactoryBot.create(:event, attendance_limit: 0) }
      it { expect(event.full?).to be_falsey }
    end
  end

  describe '#registration_price_for' do
    let(:full_price) { 930.00 }
    let(:event) { FactoryBot.create(:event, full_price: full_price) }
    let!(:attendance) { FactoryBot.create :attendance, event: event }

    context 'with one registration period' do
      let(:final_price) { 100 }
      let!(:registration_period) { FactoryBot.create :registration_period, event: event, start_at: 1.week.ago, end_at: 1.month.from_now }

      subject!(:event_value) { event.registration_price_for(attendance, 'gateway') }
      it { expect(event_value).to eq final_price }
    end

    context 'with two registrations periods, one passed and one current' do
      let(:past_price) { 200 }
      let(:final_price) { 100 }
      let!(:registration_period) { FactoryBot.create :registration_period, event: event, start_at: 1.week.ago, end_at: 1.month.from_now }
      let!(:period_passed) { FactoryBot.create :registration_period, event: event, start_at: 1.month.ago, end_at: 2.weeks.ago, price: past_price }

      it { expect(event.registration_price_for(attendance, 'gateway')).to eq final_price }
    end

    context 'with one registration quota with vacancy and opened' do
      let(:final_price) { 40 }
      let!(:registration_quota) { FactoryBot.create :registration_quota, event: event, quota: 25 }

      it { expect(event.registration_price_for(attendance, 'gateway')).to eq final_price }
    end

    context 'with one registration quota with vacancy and closed' do
      let!(:registration_quota) { FactoryBot.create :registration_quota, event: event, quota: 25, closed: true }

      context 'and not null event full price' do
        it { expect(event.registration_price_for(attendance, 'gateway')).to eq event.full_price }
      end
    end

    context 'with no quotas or period' do
      let(:event_nil_full_price) { FactoryBot.build(:event, full_price: nil) }

      context 'with a valid event full price' do
        it { expect(event.registration_price_for(attendance, 'gateway')).to eq event.full_price }
      end

      context 'with an invalid event full price' do
        it { expect(event_nil_full_price.registration_price_for(attendance, 'gateway')).to eq 0 }
      end
    end

    context 'with one passed period and one registration quota with vacancy and opened' do
      let!(:period_passed) { FactoryBot.create :registration_period, event: event, start_at: 1.month.ago, end_at: 2.weeks.ago }
      let!(:registration_quota) { FactoryBot.create :registration_quota, event: event, quota: 25, price: 20 }

      it { expect(event.registration_price_for(attendance, 'gateway')).to eq registration_quota.price }
    end

    context 'with one valid period and one registration quota with vacancy and opened' do
      let!(:registration_period) { FactoryBot.create :registration_period, event: event, start_at: 1.week.ago, end_at: 1.month.from_now }
      let!(:registration_quota) { FactoryBot.create :registration_quota, event: event, quota: 25 }

      it { expect(event.registration_price_for(attendance, 'gateway')).to eq registration_period.price }
    end

    context 'with one passed period and no quota vacancy' do
      let!(:period_passed) { FactoryBot.create :registration_period, event: event, start_at: 1.month.ago, end_at: 2.weeks.ago }
      it { expect(event.registration_price_for(attendance, 'gateway')).to eq event.full_price }
    end

    context 'and with three quotas, one with limit reached, and other two not' do
      context 'only active attendances' do
        it 'get the next quota, respecting the order' do
          forty_attendances = FactoryBot.create_list(:attendance, 40, event: event)
          FactoryBot.create :registration_quota, event: event, attendances: forty_attendances, quota: 25, order: 1

          twenty_five_attendances = FactoryBot.create_list(:attendance, 25, event: event)
          FactoryBot.create :registration_quota, event: event, attendances: twenty_five_attendances, quota: 40, order: 3, price: 700
          final_price = 470
          FactoryBot.create :registration_quota, event: event, quota: 40, order: 2, price: final_price

          expect(event.registration_price_for(attendance, 'gateway')).to eq final_price
        end
      end

      context 'only cancelled attendances' do
        it 'get the quote, ignoring the cancelleds' do
          forty_attendances = FactoryBot.create_list(:attendance, 40, event: event, status: 'cancelled')
          final_price = 360
          FactoryBot.create :registration_quota, event: event, attendances: forty_attendances, quota: 25, order: 1, price: final_price

          expect(event.registration_price_for(attendance, 'gateway')).to eq final_price
        end
      end
    end

    context 'when attendace is member of a registration group' do
      let(:group_30) { FactoryBot.create :registration_group, event: event, discount: 30 }
      let(:grouped_attendance) { FactoryBot.create(:attendance, event: event, registration_group: group_30) }

      it { expect(event.registration_price_for(grouped_attendance, 'gateway')).to eq full_price * (1.00 - (group_30.discount / 100.00)) }
    end

    context 'when payment type is statement of agreement' do
      subject!(:event_value) { event.registration_price_for(attendance, 'statement_agreement') }
      it { expect(event_value).to eq event.full_price }
    end
  end

  context 'scopes' do
    describe '.active_for' do
      context 'with one event available and other with end date at past year' do
        let!(:event) { FactoryBot.create :event, start_date: Time.zone.yesterday, end_date: Time.zone.tomorrow }
        let!(:other_event) { FactoryBot.create :event, start_date: 1.year.ago, end_date: 1.year.ago }
        it { expect(Event.active_for(Time.zone.today)).to match_array [event] }
      end

      context 'with two events available and other with end date at past year' do
        let!(:event) { FactoryBot.create :event, start_date: Time.zone.yesterday, end_date: Time.zone.tomorrow }
        let!(:other_event_valid) { FactoryBot.create :event, start_date: Time.zone.yesterday, end_date: Time.zone.tomorrow }
        let!(:other_event) { FactoryBot.create :event, start_date: 1.year.ago, end_date: 1.year.ago }
        it { expect(Event.active_for(Time.zone.today)).to match_array [event, other_event_valid] }
      end
    end

    describe '.not_started' do
      context 'when the event has started' do
        let!(:started) { FactoryBot.create(:event, start_date: 2.days.ago, end_date: 2.days.from_now) }
        let!(:not_started) { FactoryBot.create(:event, start_date: 2.days.from_now, end_date: 3.days.from_now) }
        it { expect(Event.not_started).to eq [not_started] }
      end
    end

    describe '.ended' do
      context 'and one at the right period and other not' do
        let!(:event) { FactoryBot.create(:event, start_date: 3.months.ago, end_date: 2.months.ago) }
        let!(:out) { FactoryBot.create(:event, start_date: 1.day.ago, end_date: 1.year.from_now) }

        it { expect(Event.ended).to eq [event] }
      end
    end
  end

  describe '#period_for' do
    let(:event) { FactoryBot.build(:event) }
    context 'with one period' do
      let!(:registration_period) { FactoryBot.create :registration_period, event: event, start_at: 1.week.ago, end_at: 1.month.from_now }
      it { expect(event.period_for).to eq registration_period }
    end

    context 'with no period' do
      it { expect(event.period_for).to eq nil }
    end
  end

  describe '#find_quota' do
    let(:event) { FactoryBot.build(:event) }
    context 'with one quota' do
      let!(:registration_quota) { FactoryBot.create :registration_quota, event: event, quota: 25 }
      it { expect(event.find_quota.first).to eq registration_quota }
    end

    context 'with no quota' do
      it { expect(event.find_quota).to eq [] }
    end
  end

  describe '#started' do
    context 'when the event has started' do
      let(:event) { FactoryBot.build(:event, start_date: 2.days.ago, end_date: 2.days.from_now) }
      it { expect(event.started).to be_truthy }
    end

    context 'when the event has not started' do
      let(:event) { FactoryBot.build(:event, start_date: 2.days.from_now, end_date: 3.days.from_now) }
      it { expect(event.started).to be_falsey }
    end
  end

  describe '#add_organizer' do
    let(:event) { FactoryBot.create :event }
    context 'and the user is not an organizer' do
      let(:organizer) { FactoryBot.create :organizer }
      it 'adds the user' do
        event.add_organizer(organizer)
        expect(event.reload.organizers).to eq [organizer]
      end
    end
    context 'and the user is already an organizer' do
      let(:organizer) { FactoryBot.create :organizer }
      before do
        event.organizers << organizer
        event.save!
      end
      it 'does not add the user twice' do
        expect(event.add_organizer(organizer)).to be true
        expect(event.reload.organizers.count).to eq 1
      end
    end
    context 'and the user has the admin role' do
      let(:admin) { FactoryBot.create :admin }
      it 'adds the user as organizer' do
        expect(event.add_organizer(admin)).to be true
        expect(event.reload.organizers).to include admin
      end
    end
  end

  describe '#remove_organizer' do
    let(:event) { FactoryBot.create :event }
    let(:organizer) { FactoryBot.create :organizer }

    context 'and the user is already an organizer' do
      it 'removes the user as organizer' do
        event.organizers << organizer
        event.save!
        event.remove_organizer(organizer)
        expect(event.reload.organizers.count).to eq 0
      end
    end
    context 'and the user is not an organizer of the event' do
      let(:organizer) { FactoryBot.create :organizer }
      it 'does nothing' do
        event.remove_organizer(organizer)
        expect(event.reload.organizers.count).to eq 0
      end
    end
  end

  describe '#contains?' do
    let(:user) { FactoryBot.create :user }
    let(:event) { FactoryBot.create :event }
    context 'with no cancelled attendance' do
      let!(:attendance) { FactoryBot.create :attendance, user: user, event: event }
      it { expect(event.contains?(user)).to be_truthy }
    end
    context 'with a cancelled attendance' do
      let!(:attendance) { FactoryBot.create :attendance, user: user, event: event, status: :cancelled }
      it { expect(event.contains?(user)).to be_falsey }
    end
  end

  describe '#attendances_in_the_queue?' do
    let(:event) { FactoryBot.create :event }

    context 'with an attendance in the queue' do
      let!(:waiting) { FactoryBot.create :attendance, event: event, status: :waiting }
      it { expect(event.attendances_in_the_queue?).to be_truthy }
    end

    context 'with no attendance in the queue' do
      let!(:pending) { FactoryBot.create :attendance, event: event, status: :pending }
      it { expect(event.attendances_in_the_queue?).to be_falsey }
    end
  end

  describe '#queue_average_time' do
    let(:event) { FactoryBot.create :event }
    context 'having queue time' do
      let!(:attendance) { FactoryBot.create :attendance, event: event, queue_time: 20 }
      let!(:other_attendance) { FactoryBot.create :attendance, event: event, queue_time: 10 }
      it { expect(event.queue_average_time).to eq 15 }
    end
    context 'no queue time' do
      context 'having attendances' do
        let!(:attendance) { FactoryBot.create :attendance, event: event, queue_time: 0 }
        let!(:other_attendance) { FactoryBot.create :attendance, event: event, queue_time: 0 }
        it { expect(event.queue_average_time).to eq 0 }
      end
      context 'and no attendances' do
        it { expect(event.queue_average_time).to eq 0 }
      end
    end
  end

  describe '#agile_alliance_discount_group?' do
    let(:event) { FactoryBot.create :event }
    context 'when the event has an AA discount group' do
      let!(:aa_group) { FactoryBot.create(:registration_group, event: event, name: 'Membros da Agile Alliance') }
      it { expect(event.agile_alliance_discount_group?).to be_truthy }
    end
    context 'when the event does not have an AA discount group' do
      it { expect(event.agile_alliance_discount_group?).to be_falsey }
    end
  end

  describe '#agile_alliance_discount_group' do
    let(:event) { FactoryBot.create :event }
    context 'when the event has an AA discount group' do
      let!(:aa_group) { FactoryBot.create(:registration_group, event: event, name: 'Membros da Agile Alliance') }
      it { expect(event.agile_alliance_discount_group).to eq aa_group }
    end
    context 'when the event does not have an AA discount group' do
      it { expect(event.agile_alliance_discount_group).to be_nil }
    end
  end

  describe '#capacity_left' do
    let(:event) { FactoryBot.create :event, attendance_limit: 10 }
    let!(:group) { FactoryBot.create :registration_group, event: event, paid_in_advance: true, capacity: 3, amount: 100 }
    let!(:attendance) { FactoryBot.create :attendance, event: event }

    it { expect(event.capacity_left).to eq 6 }
  end

  describe '#attendances_count' do
    let(:event) { FactoryBot.create :event }
    let!(:group) { FactoryBot.create :registration_group, event: event, paid_in_advance: true, capacity: 3, amount: 100 }
    let!(:attendance) { FactoryBot.create :attendance, event: event }
    let!(:other_attendance) { FactoryBot.create :attendance, event: event, registration_group: group }
    it { expect(event.attendances_count).to eq 4 }
  end

  describe '#reserved_count' do
    let(:event) { FactoryBot.create :event }
    let!(:group) { FactoryBot.create :registration_group, event: event, paid_in_advance: true, capacity: 3, amount: 100 }
    let!(:attendance) { FactoryBot.create :attendance, event: event, registration_group: group }
    it { expect(event.reserved_count).to eq 2 }
  end

  describe '#average_ticket' do
    let(:event) { FactoryBot.create :event }

    context 'having attendances' do
      let!(:paid_attendance) { FactoryBot.create :attendance, event: event, status: :paid }
      let!(:confirmed_attendance) { FactoryBot.create :attendance, event: event, status: :confirmed }
      let!(:showed_attendance) { FactoryBot.create :attendance, event: event, status: :showed_in }
      let!(:pending_attendance) { FactoryBot.create :attendance, event: event, status: :pending }
      let!(:waiting_attendance) { FactoryBot.create :attendance, event: event, status: :waiting }
      let!(:cancelled_attendance) { FactoryBot.create :attendance, event: event, status: :cancelled }

      it { expect(event.average_ticket).to eq 400 }
    end

    context 'having no attendances' do
      it { expect(event.average_ticket).to eq 0 }
    end
  end
end
