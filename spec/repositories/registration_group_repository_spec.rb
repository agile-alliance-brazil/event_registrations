describe RegistrationGroupRepository, type: :repository do
  describe '#reserved_for_quota' do
    let(:quota) { FactoryGirl.create :registration_quota }
    let!(:group) { FactoryGirl.create :registration_group, paid_in_advance: true, capacity: 5, amount: 100, registration_quota: quota }
    let!(:other_group) { FactoryGirl.create :registration_group, paid_in_advance: true, capacity: 5, amount: 100, registration_quota: quota }
    let!(:out_group) { FactoryGirl.create :registration_group, paid_in_advance: false, capacity: 5, registration_quota: quota }
    it { expect(RegistrationGroupRepository.instance.reserved_for_quota(quota)).to eq 10 }
  end

  describe '#reserved_for_event' do
    let(:event) { FactoryGirl.create :event }
    let!(:group) { FactoryGirl.create :registration_group, paid_in_advance: true, capacity: 5, amount: 100, event: event }
    let!(:other_group) { FactoryGirl.create :registration_group, paid_in_advance: true, capacity: 5, amount: 100, event: event }
    let!(:out_group) { FactoryGirl.create :registration_group, paid_in_advance: false, capacity: 5, event: event }
    let!(:attendance) { FactoryGirl.create :attendance, registration_group: group }
    let!(:other_attendance) { FactoryGirl.create :attendance, registration_group: group, status: :cancelled }

    it { expect(RegistrationGroupRepository.instance.reserved_for_event(event)).to eq 9 }
  end
end
