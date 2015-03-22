describe RegistrationGroup, type: :model do
  context 'associations' do
    it { should have_many :attendances }
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
end