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
      let(:registration_quota) { Fabricate :registration_quota, quota: 23 }

      context 'with vacancy' do
        let(:attendances) { Fabricate.times(20, :attendance) }

        before { registration_quota.attendances = attendances }

        it { expect(registration_quota).to be_vacancy }
      end

      context 'without vacancy' do
        let(:attendances) { Fabricate.times(23, :attendance) }

        before { registration_quota.attendances = attendances }

        it { expect(registration_quota).not_to be_vacancy }
      end
    end

    context 'with paid registration_groups registered during the quota' do
      let(:quota) { Fabricate :registration_quota, quota: 10 }

      context 'with no vacancy' do
        let!(:group) { Fabricate :registration_group, paid_in_advance: true, capacity: 5, amount: 100, registration_quota: quota }
        let!(:other_group) { Fabricate :registration_group, paid_in_advance: true, capacity: 5, amount: 100, registration_quota: quota }

        it { expect(quota).not_to be_vacancy }
      end

      context 'with vacancy' do
        let!(:group) { Fabricate :registration_group, paid_in_advance: true, capacity: 5, amount: 100, registration_quota: quota }

        it { expect(quota).to be_vacancy }
      end
    end
  end
end
