describe RegistrationGroup, type: :model do
  let(:event) { FactoryGirl.create :event }
  let(:group) { RegistrationGroup.create! event: event }

  context 'associations' do
    it { should have_many :attendances }
    it { should have_many :invoices }
    pending 'Actually should have one invoice and not many. Change prior test and behaviour.'

    it { should belong_to :event }
    it { expect(group).to belong_to(:leader).class_name('User') }
  end

  context 'validations' do
    it { should validate_presence_of :event }
  end

  describe '#destroy' do
    context 'mark attendances as cancelled' do
      let(:group) { RegistrationGroup.create! event: event }
      before do
        2.times { FactoryGirl.create :attendance, registration_group: group }
        group.destroy
        @attendances = Attendance.where(registration_group: group.id)
      end
      it { expect(RegistrationGroup.all).not_to include(group) }
      it { expect(@attendances.map(&:status).uniq).to eq(["cancelled"]) }
    end

    context 'do not destroy when attendance could not be cancelled' do
      let(:group) { RegistrationGroup.create! event: event }
      before do
        2.times { @last_attendance = FactoryGirl.create(:attendance, registration_group: group) }
        @last_attendance.pay
        group.destroy
        @attendances = Attendance.where(registration_group: group.id)
      end
      it { expect(RegistrationGroup.all).to include(group) }
      it { expect(@attendances.map(&:status)).to eq %w(pending paid) }
    end
  end

  describe '#generate_token' do
    let(:event) { FactoryGirl.create :event }
    let(:group) { RegistrationGroup.create! event: event }
    before { SecureRandom.expects(:hex).returns('eb693ec8252cd630102fd0d0fb7c3485') }
    it { expect(group.token).to eq 'eb693ec8252cd630102fd0d0fb7c3485' }
  end

  describe '#qtd_attendances' do
    context 'just pending attendances' do
      let(:group) { RegistrationGroup.create! event: event }
      before { 2.times { FactoryGirl.create :attendance, registration_group: group } }
      it { expect(group.qtd_attendances).to eq 2 }
    end

    context 'with cancelled attendances' do
      let(:group) { RegistrationGroup.create! event: event }
      before do
        2.times { @last_attendance = FactoryGirl.create(:attendance, registration_group: group) }
        @last_attendance.cancel
      end
      it { expect(group.qtd_attendances).to eq 1 }
    end
  end

  describe '#total_price' do
    let(:individual) { event.registration_types.first }
    let(:group) { RegistrationGroup.create! event: event }

    context 'with one attendance and 20% discount over full price' do
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group) }
      it { expect(group.total_price).to eq 400.00 }
    end

    context 'with more attendances and 20% discount' do
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group, registration_value: 440.00) }
      let!(:other) { FactoryGirl.create(:attendance, event: event, registration_group: group, registration_value: 530.00) }
      let!(:another) { FactoryGirl.create(:attendance, event: event, registration_group: group, registration_value: 700.00) }
      it { expect(group.total_price).to eq 1670.00 }
    end

    context 'when has cancelled attendances' do
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group, registration_value: 440.00) }
      let!(:other) { FactoryGirl.create(:attendance, event: event, registration_group: group, registration_value: 530.00) }
      before { other.cancel }
      it { expect(group.total_price).to eq 440.00 }
    end
  end

  describe '#price?' do
    let(:individual) { event.registration_types.first }
    let!(:period) { RegistrationPeriod.create(event: event, start_at: 1.month.ago, end_at: 1.month.from_now) }
    let!(:price) { RegistrationPrice.create!(registration_type: individual, registration_period: period, value: 100.00) }
    let(:group) { RegistrationGroup.create! event: event, discount: 20 }

    context 'without attendances' do
      it { expect(group.price?).to be_falsey }
    end

    context 'with attendances' do
      context 'and no value' do
        let(:group) { RegistrationGroup.create! event: event }
        let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group, registration_value: 0) }
        it { expect(group.price?).to be_falsey }
      end

      context 'and having value' do
        let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group) }
        it { expect(group.price?).to be_truthy }
      end
    end
  end

  describe '#update_invoice' do
    let(:group) { RegistrationGroup.create! event: event, discount: 100 }
    context 'with a pending invoice' do
      let!(:invoice) { FactoryGirl.create :invoice, registration_group: group, amount: 100.00 }
      it 'will change the invoice amount' do
        group.stubs(:total_price).returns 200.00
        group.update_invoice
        expect(Invoice.last.amount).to eq 200.00
      end
    end

    context 'with a not pending invoice' do
      let!(:invoice) { FactoryGirl.create :invoice, registration_group: group, amount: 100.00, status: Invoice::PAID }
      it 'will not change the invoice amount' do
        group.stubs(:total_price).returns 200.00
        group.update_invoice
        expect(Invoice.last.amount).to eq 100.00
      end
    end
  end

  describe '#update_invoice' do
    let(:group) { RegistrationGroup.create! event: event, discount: 100 }
    context 'with a pending invoice' do
      let!(:invoice) { FactoryGirl.create :invoice, registration_group: group, amount: 100.00 }
      it 'will change the invoice amount' do
        group.stubs(:total_price).returns 200.00
        group.update_invoice
        expect(Invoice.last.amount).to eq 200.00
      end
    end

    context 'with a not pending invoice' do
      let!(:invoice) { FactoryGirl.create :invoice, registration_group: group, amount: 100.00, status: Invoice::PAID }
      it 'will not change the invoice amount' do
        group.stubs(:total_price).returns 200.00
        group.update_invoice
        expect(Invoice.last.amount).to eq 100.00
      end
    end
  end

  describe '#accept_members?' do
    let(:group) { RegistrationGroup.create! event: event, discount: 100 }

    context 'with a pending invoice' do
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group, status: 'pending') }
      it { expect(group.accept_members?).to be_truthy }
    end

    context 'with a paid group' do
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group, status: 'paid') }
      it { expect(group.accept_members?).to be_falsey }
    end
  end

  describe '#payment_pendent?' do
    context 'consistent data' do
      context 'with one pendent' do
        let(:group) { RegistrationGroup.create! event: event, discount: 20 }
        let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group, status: 'pending') }
        it { expect(group.paid?).to be_falsey }
      end

      context 'with one paid' do
        let(:group) { RegistrationGroup.create! event: event, discount: 20 }
        let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group, status: 'paid') }
        it { expect(group.paid?).to be_truthy }
      end
    end

    context 'with inconsistent data' do
      context 'with one paid and one pendent' do
        let(:group) { RegistrationGroup.create! event: event, discount: 20 }
        let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group, status: 'paid') }
        let!(:other_attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group, status: 'pending') }
        it { expect(group.paid?).to be_truthy }
      end
    end
  end

  describe '#leader_name' do
    let(:user) { FactoryGirl.create :user }
    context 'with a defined leader' do
      let(:group) { RegistrationGroup.create! event: event, discount: 20, leader: user }
      it { expect(group.leader_name).to eq user.full_name }
    end

    context 'with a defined leader' do
      let(:group) { RegistrationGroup.create! event: event }
      it { expect(group.leader_name).to eq nil }
    end
  end
end
