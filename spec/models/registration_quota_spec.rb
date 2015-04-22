describe RegistrationQuota, type: :model do
  context 'associations' do
    it { should have_many :attendances }
    it { should belong_to :event }
    it { should belong_to :registration_price }
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
