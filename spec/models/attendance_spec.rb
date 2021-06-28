# frozen_string_literal: true

RSpec.describe Attendance, type: :model do
  context 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(waiting: 0, pending: 1, accepted: 2, cancelled: 3, paid: 4, confirmed: 5, showed_in: 6) }
    it { is_expected.to define_enum_for(:job_role).with_values(not_informed: 0, student: 1, analyst: 2, manager: 3, vp: 4, president: 5, designer: 6, coach: 7, other: 8, developer: 9, teacher: 10, independent_worker: 11, team_manager: 12, portfolio_manager: 13, human_resources: 14) }
    it { is_expected.to define_enum_for(:payment_type).with_values(gateway: 1, bank_deposit: 2, statement_agreement: 3) }
    it { is_expected.to define_enum_for(:source_of_interest).with_values(no_source_informed: 0, facebook: 1, instagram: 2, linkedin: 3, twitter: 4, whatsapp: 5, friend_referral: 6, community_dissemination: 7, company_dissemination: 8, internet_search: 9) }
    it { is_expected.to define_enum_for(:years_of_experience).with_values(no_experience_informed: 0, less_than_five: 1, six_to_ten: 2, eleven_to_twenty: 3, twenty_one_to_thirty: 4, thirty_or_more: 5) }
    it { is_expected.to define_enum_for(:experience_in_agility).with_values(no_agile_expirience_informed: 0, less_than_two: 1, three_to_seven: 2, more_than_seven: 3) }
    it { is_expected.to define_enum_for(:organization_size).with_values(no_org_size_informed: 0, micro_enterprises: 1, small_enterprises: 2, medium_enterprises: 3, large_enterprises: 4) }
  end

  context 'associations' do
    it { is_expected.to belong_to :event }
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :registration_group }
    it { is_expected.to belong_to :registration_quota }
    it { is_expected.to have_many :payment_notifications }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :country }
    it { is_expected.to validate_presence_of :city }
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :event }

    it { is_expected.to validate_presence_of :state }
  end

  context 'scopes' do
    context 'for statuses' do
      let!(:pending) { Fabricate(:attendance, status: :pending) }
      let!(:accepted) { Fabricate(:attendance, status: :accepted) }
      let!(:paid) { Fabricate(:attendance, status: :paid) }
      let!(:confirmed) { Fabricate(:attendance, status: :confirmed) }
      let!(:showed_in) { Fabricate(:attendance, status: :showed_in) }
      let!(:cancelled) { Fabricate(:attendance, status: :cancelled) }
      let!(:waiting) { Fabricate(:attendance, status: :waiting) }

      describe '.pending' do
        it { expect(described_class.pending).to eq [pending] }
      end

      describe '.accepted' do
        it { expect(described_class.accepted).to eq [accepted] }
      end

      describe '.waiting' do
        it { expect(described_class.waiting).to eq [waiting] }
      end

      describe '.confirmed' do
        it { expect(described_class.confirmed).to eq [confirmed] }
      end

      describe '.cancelled' do
        it { expect(described_class.cancelled).to eq [cancelled] }
      end

      describe '.paid' do
        it { expect(described_class.paid).to eq [paid] }
      end

      describe '.commited_to' do
        it { expect(described_class.committed_to).to match_array [confirmed, paid, showed_in] }
      end

      describe '.active' do
        it { expect(described_class.active).to eq [pending, accepted, paid, confirmed, showed_in] }
      end
    end

    context 'complex ones' do
      describe '.last_biweekly_active' do
        let!(:last_week) { Fabricate(:attendance, created_at: 7.days.ago) }
        let!(:other_last_week) { Fabricate(:attendance, created_at: 7.days.ago) }
        let!(:today) { Fabricate(:attendance) }
        let!(:out) { Fabricate(:attendance, created_at: 21.days.ago) }

        it { expect(described_class.last_biweekly_active).to eq [last_week, other_last_week, today] }
      end

      describe '.waiting_approval' do
        let(:group) { Fabricate(:registration_group) }
        let!(:pending) { Fabricate(:attendance, registration_group: group, status: :pending) }
        let!(:out_pending) { Fabricate(:attendance, status: :pending) }
        let!(:accepted) { Fabricate(:attendance, registration_group: group, status: :accepted) }
        let!(:paid) { Fabricate(:attendance, registration_group: group, status: :paid) }
        let!(:confirmed) { Fabricate(:attendance, registration_group: group, status: :confirmed) }

        it { expect(described_class.waiting_approval).to eq [pending] }
      end

      describe '.non_free' do
        let!(:pending) { Fabricate(:attendance, status: :pending, registration_value: 100) }
        let!(:accepted) { Fabricate(:attendance, status: :accepted, registration_value: 0) }

        it { expect(described_class.non_free).to eq [pending] }
      end

      describe '.with_time_in_queue' do
        let!(:attendance) { Fabricate :attendance, queue_time: 100 }
        let!(:other_attendance) { Fabricate :attendance, queue_time: 2 }
        let!(:out_attendance) { Fabricate :attendance, queue_time: 0 }

        it { expect(described_class.with_time_in_queue).to match_array [attendance, other_attendance] }
      end
    end
  end

  describe '#cancellable?' do
    let(:attendance) { Fabricate.build(:attendance, status: :pending) }

    context 'when is waiting' do
      let(:waiting) { Fabricate.build(:attendance, status: :waiting) }

      it { expect(waiting).to be_cancellable }
    end

    context 'when is pending' do
      it { expect(attendance).to be_cancellable }
    end

    context 'when is accepted' do
      before { attendance.accepted! }

      it { expect(attendance).to be_cancellable }
    end

    context 'when is paid' do
      before { attendance.paid! }

      it { expect(attendance).to be_cancellable }
    end

    context 'when is confirmed' do
      before { attendance.confirmed! }

      it { expect(attendance).to be_cancellable }
    end

    context 'when is already cancelled' do
      before { attendance.cancelled! }

      it { expect(attendance).not_to be_cancellable }
    end
  end

  describe '#confirmable?' do
    let(:attendance) { Fabricate.build(:attendance, status: :pending) }

    context 'when is pending' do
      it { expect(attendance).to be_confirmable }
    end

    context 'when is accepted' do
      before { attendance.accepted! }

      it { expect(attendance).to be_confirmable }
    end

    context 'when is paid' do
      context 'and grouped' do
        let(:group) { Fabricate(:registration_group) }
        let(:grouped_attendance) { Fabricate(:attendance, registration_group: group) }

        before { grouped_attendance.paid! }

        it { expect(grouped_attendance).to be_confirmable }
      end
    end

    context 'when it is already confirmed' do
      before { attendance.confirmed! }

      it { expect(attendance).not_to be_confirmable }
    end
  end

  describe '#recoverable?' do
    let(:attendance) { Fabricate.build(:attendance, status: :pending) }

    context 'when is pending' do
      it { expect(attendance).not_to be_recoverable }
    end

    context 'when it is accepted' do
      before { attendance.accepted! }

      it { expect(attendance).not_to be_recoverable }
    end

    context 'when it is paid' do
      before { attendance.paid! }

      it { expect(attendance).not_to be_recoverable }
    end

    context 'when it is cancelled' do
      before { attendance.cancelled! }

      it { expect(attendance).to be_recoverable }
    end
  end

  describe '#payable?' do
    let(:attendance) { Fabricate.build(:attendance, status: :pending) }

    context 'when is pending' do
      it { expect(attendance).to be_payable }
    end

    context 'when it is accepted' do
      before { attendance.accepted! }

      it { expect(attendance).to be_payable }
    end

    context 'when it is paid' do
      before { attendance.paid! }

      it { expect(attendance).not_to be_payable }
    end

    context 'when it is cancelled' do
      before { attendance.cancelled! }

      it { expect(attendance).not_to be_payable }
    end

    context 'when it is confirmed' do
      before { attendance.confirmed! }

      it { expect(attendance).not_to be_payable }
    end
  end

  describe '#discount' do
    let(:event) { Fabricate(:event) }

    context 'when is not member of a group' do
      let!(:attendance) { Fabricate(:attendance, event: event) }

      it { expect(attendance.discount).to eq 1 }
    end

    context 'when is member of a 30% group' do
      let(:group) { Fabricate(:registration_group, event: event, discount: 30) }
      let!(:attendance) { Fabricate(:attendance, event: event, registration_group: group) }

      it { expect(attendance.discount).to eq 0.7 }
    end

    context 'when is member of a 100% group' do
      let(:group) { Fabricate(:registration_group, event: event, discount: 100) }
      let!(:attendance) { Fabricate(:attendance, event: event, registration_group: group) }

      it { expect(attendance.discount).to eq 0 }
    end

    context 'when the discount is nil' do
      let(:group) { Fabricate(:registration_group, event: event, discount: nil, amount: 100) }
      let!(:attendance) { Fabricate(:attendance, event: event, registration_group: group) }

      it { expect(attendance.discount).to eq 1 }
    end
  end

  describe '#group_name' do
    let(:event) { Fabricate(:event) }

    context 'with a registration group' do
      let!(:group) { Fabricate :registration_group, event: event }
      let!(:attendance) { Fabricate(:attendance, event: event, registration_group: group) }

      it { expect(attendance.group_name).to eq group.name }
    end

    context 'with no registration group' do
      let!(:attendance) { Fabricate(:attendance, event: event) }

      it { expect(attendance.group_name).to eq nil }
    end
  end

  describe '#event_name' do
    context 'with an event' do
      let(:event) { Fabricate(:event) }
      let!(:attendance) { Fabricate(:attendance, event: event) }

      it { expect(attendance.event_name).to eq event.name }
    end
  end

  describe '#grouped?' do
    let(:event) { Fabricate(:event) }

    context 'when belongs to a group' do
      let(:group) { Fabricate :registration_group, event: event }
      let!(:attendance) { Fabricate(:attendance, event: event, registration_group: group) }

      it { expect(attendance).to be_grouped }
    end

    context 'when not belonging to a group' do
      let!(:attendance) { Fabricate(:attendance, event: event) }

      it { expect(attendance).not_to be_grouped }
    end
  end

  describe '#advise!' do
    context 'when the due date is in a workday' do
      let(:event) { Fabricate :event, days_to_charge: 1 }
      let!(:attendance) { Fabricate(:attendance, event: event) }

      it 'send an advice to the attendance' do
        travel_to Time.zone.local(2017, 5, 4, 0, 0, 0) do
          attendance.advise!
          expect(described_class.last.advised).to be_truthy
          expect(described_class.last.advised_at).to eq Time.zone.local(2017, 5, 4, 0, 0, 0)
          expect(described_class.last.due_date).to eq Time.zone.local(2017, 5, 5, 0, 0, 0)
        end
      end
    end

    context 'when the due date is in a weekend' do
      let(:event) { Fabricate :event, days_to_charge: 1 }
      let!(:attendance) { Fabricate(:attendance, event: event) }

      it 'send the advice in the next business day' do
        travel_to Time.zone.local(2017, 5, 6, 0, 0, 0) do
          attendance.advise!
          expect(described_class.last.due_date).to eq Time.zone.local(2017, 5, 8, 0, 0, 0)
        end
      end
    end

    context 'when the event start date is before the attendance due date' do
      let(:event) { Fabricate :event, start_date: Date.new(2017, 5, 8), days_to_charge: 5 }
      let!(:attendance) { Fabricate(:attendance, event: event) }

      before { attendance.advise! }

      it { expect(described_class.last.due_date).to eq Time.zone.local(2017, 5, 8, 0, 0, 0) }
    end
  end

  context 'delegations' do
    describe '#token' do
      let(:group) { Fabricate :registration_group }
      let(:attendance) { Fabricate :attendance, registration_group: group }

      it { expect(attendance.token).to eq group.token }
      it { expect(attendance.group_name).to eq group.name }
      it { expect(attendance.event_name).to eq attendance.event.name }
    end
  end

  describe '#price_band?' do
    context 'having period' do
      let(:period) { Fabricate(:registration_period) }
      let!(:attendance) { Fabricate(:attendance, registration_period: period) }

      it { expect(attendance).to be_price_band }
    end

    context 'having quota' do
      let(:quota) { Fabricate(:registration_quota) }
      let!(:attendance) { Fabricate(:attendance, registration_quota: quota) }

      it { expect(attendance).to be_price_band }
    end

    context 'having no bands' do
      let!(:attendance) { Fabricate(:attendance) }

      it { expect(attendance).not_to be_price_band }
    end
  end

  describe '#band_value' do
    context 'having period' do
      let(:period) { Fabricate(:registration_period) }
      let!(:attendance) { Fabricate(:attendance, registration_period: period) }

      it { expect(attendance.band_value).to eq period.price }
    end

    context 'having quota' do
      let(:quota) { Fabricate(:registration_quota) }
      let!(:attendance) { Fabricate(:attendance, registration_quota: quota) }

      it { expect(attendance.band_value).to eq quota.price }
    end

    context 'having no bands' do
      let!(:attendance) { Fabricate(:attendance) }

      it { expect(attendance.band_value).to be_nil }
    end
  end

  describe '#accepted!' do
    context 'when the value is not zero' do
      let(:period) { Fabricate(:registration_period) }
      let!(:attendance) { Fabricate(:attendance, registration_period: period, registration_value: 10) }
      let!(:other_attendance) { Fabricate(:attendance, registration_period: period, registration_value: -10) }
      let!(:zero_attendance) { Fabricate(:attendance, registration_period: period, registration_value: 0) }

      before do
        attendance.accepted!
        other_attendance.accepted!
        zero_attendance.accepted!
      end

      it { expect(attendance.reload).to be_accepted }
      it { expect(other_attendance.reload).to be_accepted }
      it { expect(zero_attendance.reload).to be_paid }
    end
  end
end
