# == Schema Information
#
# Table name: registration_types
#
#  id         :integer          not null, primary key
#  event_id   :integer
#  title      :string
#  created_at :datetime
#  updated_at :datetime
#

describe RegistrationType, type: :model do
  context 'associations' do
    it { should belong_to :event }
    it { should have_many :registration_prices }
  end

  context 'scopes' do
    describe '.individual' do
      let!(:registration_type) { FactoryGirl.create(:registration_type, title: 'registration_type.individual') }
      it { expect(RegistrationType.individual.last).to eq registration_type }
    end
  end

  describe '#price' do
    context 'with a valid registration period' do
      it 'delegates to RegistrationPeriod' do
        time = Time.zone.now
        type = FactoryGirl.build(:registration_type)
        price = RegistrationPeriod.new

        type.event.registration_periods.expects(:for).with(time).returns([price])
        price.expects(:price_for_registration_type).with(type).returns(599)

        expect(type.price(time)).to eq(599.00)
      end
    end
  end
end
