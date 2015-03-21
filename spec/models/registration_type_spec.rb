describe RegistrationType, type: :model do
  context 'associations' do
    it { should belong_to :event }
    it { should have_many :registration_prices }
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

    context 'with no registration period' do
      let(:event) { Event.create!(name: Faker::Company.name, price_table_link: 'http://localhost:9292/link') }
      let(:registration_type) { FactoryGirl.create(:registration_type, event: event) }
      it { expect(registration_type.price(Time.now)).to eq 0 }
    end
  end
end
