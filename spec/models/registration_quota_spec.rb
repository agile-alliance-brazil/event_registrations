# == Schema Information
#
# Table name: registration_quota
#
#  id                    :integer          not null, primary key
#  quota                 :integer
#  created_at            :datetime
#  updated_at            :datetime
#  event_id              :integer
#  registration_price_id :integer
#  order                 :integer
#  closed                :boolean          default(FALSE)
#  price_cents           :integer          default(0), not null
#  price_currency        :string           default("BRL"), not null
#

describe RegistrationQuota, type: :model do
  context 'associations' do
    it { should have_many :attendances }
    it { should belong_to :event }
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
