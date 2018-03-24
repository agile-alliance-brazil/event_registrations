# frozen_string_literal: true

describe RegistrationQuota, type: :model do
  context 'associations' do
    it { is_expected.to have_many :attendances }
    it { is_expected.to belong_to :event }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :order }
    it { is_expected.to validate_presence_of :quota }
  end

  describe '#vacancy?' do
    context 'with no paid registration_groups registered during the quota' do
      let(:registration_quota) { FactoryBot.create :registration_quota, quota: 23 }
      context 'with vacancy' do
        let(:attendances) { FactoryBot.create_list(:attendance, 20) }
        before { registration_quota.attendances = attendances }
        it { expect(registration_quota.vacancy?).to be_truthy }
      end
      context 'without vacancy' do
        let(:attendances) { FactoryBot.create_list(:attendance, 23) }
        before { registration_quota.attendances = attendances }
        it { expect(registration_quota.vacancy?).to be_falsey }
      end
    end

    context 'with paid registration_groups registered during the quota' do
      let(:quota) { FactoryBot.create :registration_quota, quota: 10 }
      context 'with no vacancy' do
        let!(:group) { FactoryBot.create :registration_group, paid_in_advance: true, capacity: 5, amount: 100, registration_quota: quota }
        let!(:other_group) { FactoryBot.create :registration_group, paid_in_advance: true, capacity: 5, amount: 100, registration_quota: quota }
        it { expect(quota.vacancy?).to be_falsey }
      end
      context 'with vacancy' do
        let!(:group) { FactoryBot.create :registration_group, paid_in_advance: true, capacity: 5, amount: 100, registration_quota: quota }
        it { expect(quota.vacancy?).to be_truthy }
      end
    end
  end
end
