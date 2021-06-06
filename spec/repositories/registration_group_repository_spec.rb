# frozen_string_literal: true

describe RegistrationGroupRepository, type: :repository do
  describe '#reserved_for_quota' do
    let(:quota) { Fabricate :registration_quota }
    let!(:group) { Fabricate :registration_group, paid_in_advance: true, capacity: 5, amount: 100, registration_quota: quota }
    let!(:other_group) { Fabricate :registration_group, paid_in_advance: true, capacity: 5, amount: 100, registration_quota: quota }
    let!(:out_group) { Fabricate :registration_group, paid_in_advance: false, capacity: 5, registration_quota: quota }

    it { expect(described_class.instance.reserved_for_quota(quota)).to eq 10 }
  end

  describe '#reserved_for_event' do
    let(:event) { Fabricate :event }
    let!(:group) { Fabricate :registration_group, paid_in_advance: true, capacity: 5, amount: 100, event: event }
    let!(:other_group) { Fabricate :registration_group, paid_in_advance: true, capacity: 5, amount: 100, event: event }
    let!(:out_group) { Fabricate :registration_group, paid_in_advance: false, capacity: 5, event: event }
    let!(:attendance) { Fabricate :attendance, registration_group: group }
    let!(:other_attendance) { Fabricate :attendance, registration_group: group, status: :cancelled }

    it { expect(described_class.instance.reserved_for_event(event)).to eq 9 }
  end
end
