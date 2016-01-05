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
    let(:registration_quota) { FactoryGirl.create :registration_quota, quota: 23 }
    context 'with vacancy' do
      let(:attendances) { FactoryGirl.create_list(:attendance, 20) }
      before { registration_quota.attendances = attendances }
      it { expect(registration_quota.vacancy?).to be_truthy }
    end
  end
end
