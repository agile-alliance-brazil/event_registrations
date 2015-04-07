describe RegistrationGroup, type: :model do
  context 'associations' do
    it { should have_many :attendances }
    it { should have_many :invoices }
    it { should belong_to :event }
  end

  context 'validations' do
    it { should validate_presence_of :event }
  end

  let(:event) { FactoryGirl.create :event }

  describe '#generate_token' do
    let(:group) { RegistrationGroup.create! event: event }
    before { SecureRandom.expects(:hex).returns('eb693ec8252cd630102fd0d0fb7c3485') }
    it { expect(group.token).to eq 'eb693ec8252cd630102fd0d0fb7c3485' }
  end

  describe '#qtd_attendances' do
    let(:group) { RegistrationGroup.create! event: event }
    before { 2.times { FactoryGirl.create :attendance, registration_group: group } }
    it { expect(group.qtd_attendances).to eq 2 }
  end

  describe '#total_price' do
    let(:individual) { event.registration_types.first }
    let!(:period) { RegistrationPeriod.create(event: event, start_at: 1.month.ago, end_at: 1.month.from_now) }
    let!(:price) { RegistrationPrice.create!(registration_type: individual, registration_period: period, value: 100.00) }
    let(:group) { RegistrationGroup.create! event: event, discount: 20 }
    let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group) }

    context 'and one attendance' do
      it { expect(group.total_price).to eq 80 }
    end

    context 'and more attendances' do
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group) }
      let!(:other) { FactoryGirl.create(:attendance, event: event, registration_group: group) }
      let!(:another) { FactoryGirl.create(:attendance, event: event, registration_group: group) }
      it { expect(group.total_price).to eq (attendance.registration_fee + other.registration_fee + another.registration_fee) }
    end
  end

  describe '#has_price?' do
    let(:individual) { event.registration_types.first }
    let!(:period) { RegistrationPeriod.create(event: event, start_at: 1.month.ago, end_at: 1.month.from_now) }
    let!(:price) { RegistrationPrice.create!(registration_type: individual, registration_period: period, value: 100.00) }
    let(:group) { RegistrationGroup.create! event: event, discount: 20 }

    context 'without attendances' do
      it { expect(group.has_price?).to be_falsey }
    end

    context 'with attendances' do
      context 'and no value' do
        let(:group) { RegistrationGroup.create! event: event, discount: 100 }
        let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group) }
        it { expect(group.has_price?).to be_falsey }
      end

      context 'and having value' do
        let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group) }
        it { expect(group.has_price?).to be_truthy }
      end
    end
  end
end
