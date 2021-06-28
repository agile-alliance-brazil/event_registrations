# frozen_string_literal: true

RSpec.describe AttendanceRepository, type: :repository do
  let(:event) { Fabricate :event }

  describe '#search_for_list' do
    context 'with no attendances' do
      it { expect(described_class.instance.search_for_list(event, 'bla', [])).to eq [] }
    end

    context 'with attendances' do
      let(:all_statuses) { %w[pending accepted paid confirmed cancelled] }

      it 'searches according to the parameters' do
        user = Fabricate :user, first_name: 'bla', last_name: 'xpto', email: 'foo@xpto.com'
        other_user = Fabricate :user, first_name: 'Foo', last_name: 'Dijkstra', email: 'xpto@node.path'
        out_user = Fabricate :user, first_name: 'Edsger', last_name: 'Dijkstra', email: 'other@node.path'

        Fabricate(:attendance, user: user, organization: 'foo')
        attendance = Fabricate(:attendance, user: user, event: event, status: :pending, organization: 'foo')
        other_attendance = Fabricate(:attendance, user: other_user, event: event, status: :pending, organization: 'beatles')

        Fabricate(:attendance, user: out_user, event: event, organization: 'Turing')
        Fabricate(:attendance, user: out_user, organization: 'Turing')

        expect(described_class.instance.search_for_list(event, 'xPTo', all_statuses)).to match_array [attendance, other_attendance]
        expect(described_class.instance.search_for_list(event, 'bLa', all_statuses)).to eq [attendance]
      end
    end
  end

  describe 'for_cancelation_warning' do
    context 'with valid status and gateway as payment type' do
      it 'returns the attendance' do
        pending_gateway = Fabricate(:attendance, event: event, status: :pending, payment_type: :gateway, last_status_change_date: 7.days.ago)
        accepted_gateway = Fabricate(:attendance, event: event, status: :accepted, payment_type: :gateway, last_status_change_date: 7.days.ago)
        Fabricate(:attendance, status: :accepted, registration_date: 7.days.ago, payment_type: :gateway)
        expect(described_class.instance.for_cancelation_warning(event)).to match_array [pending_gateway, accepted_gateway]
      end
    end

    context 'with two pending and gateway as payment type' do
      it 'returns the both attendances' do
        pending_gateway = Fabricate(:attendance, event: event, status: :pending, payment_type: :gateway, last_status_change_date: 7.days.ago)
        other_pending_gateway = Fabricate(:attendance, event: event, status: :pending, payment_type: :gateway, last_status_change_date: 7.days.ago)
        expect(described_class.instance.for_cancelation_warning(event)).to eq [pending_gateway, other_pending_gateway]
      end
    end

    context 'with one pending and gateway as payment type and other bank deposit' do
      it 'returns the attendance pending gateway' do
        pending_gateway = Fabricate(:attendance, event: event, status: :pending, payment_type: :gateway, last_status_change_date: 7.days.ago)
        Fabricate(:attendance, event: event, status: :pending, last_status_change_date: 7.days.ago)
        expect(described_class.instance.for_cancelation_warning(event)).to eq [pending_gateway]
      end
    end

    context 'with a pending status and belonging to a group' do
      before { travel_to Time.zone.local(2018, 5, 16, 10, 0, 0) }

      after { travel_back }

      let!(:pending) { Fabricate(:attendance, event: event, status: :pending, payment_type: :gateway, last_status_change_date: 7.days.ago) }
      let!(:group) { Fabricate :registration_group, automatic_approval: false }
      let!(:pending_in_a_group) { Fabricate(:attendance, registration_group: group, status: :pending, event: event, payment_type: :gateway, last_status_change_date: 7.days.ago) }
      let!(:accepted_in_a_group) { Fabricate(:attendance, status: :accepted, registration_group: group, event: event, payment_type: :gateway, last_status_change_date: 7.days.ago) }

      it { expect(described_class.instance.for_cancelation_warning(event)).to match_array [pending, accepted_in_a_group] }
    end
  end

  describe '#for_cancelation' do
    let!(:to_cancel) { Fabricate(:attendance, event: event, status: :pending, payment_type: :gateway, advised_at: 8.days.ago, due_date: 1.day.ago, advised: true) }
    let!(:out) { Fabricate(:attendance, event: event, status: :pending, payment_type: :gateway, advised_at: 5.days.ago, advised: true) }
    let!(:other_out) { Fabricate(:attendance, event: event, status: :pending, advised_at: nil, advised: false, created_at: 15.days.ago) }

    it { expect(described_class.instance.for_cancelation(event)).to eq [to_cancel] }
  end

  describe '#attendances_for' do
    let(:user) { Fabricate :user }
    let!(:attendance) { Fabricate(:attendance, event: event, user: user) }
    let!(:out) { Fabricate(:attendance, user: user) }

    it { expect(described_class.instance.attendances_for(event, user)).to eq [attendance] }
  end

  describe '#for_event' do
    let(:user) { Fabricate :user }
    let!(:attendance) { Fabricate(:attendance, event: event, user: user) }
    let!(:out) { Fabricate(:attendance, user: user) }

    it { expect(described_class.instance.for_event(event)).to eq [attendance] }
  end

  describe '#event_queue' do
    let!(:first_waiting) { Fabricate :attendance, event: event, status: :waiting, created_at: 1.day.from_now }
    let!(:second_waiting) { Fabricate :attendance, event: event, status: :waiting, created_at: Time.zone.today }
    let!(:third_waiting) { Fabricate :attendance, event: event, status: :waiting, created_at: 2.days.ago }

    it { expect(described_class.instance.event_queue(event)).to match_array [third_waiting, second_waiting, first_waiting] }
  end

  describe '.older_than' do
    let(:user) { Fabricate :user }
    let!(:attendance) { Fabricate(:attendance, event: event, user: user, last_status_change_date: 2.days.ago) }
    let!(:other_attendance) { Fabricate(:attendance, event: event, user: user, last_status_change_date: 4.days.ago) }

    it { expect(described_class.instance.send(:older_than)).to match_array [attendance, other_attendance] }
    it { expect(described_class.instance.send(:older_than, 3.days.ago)).to eq [other_attendance] }
  end
end
