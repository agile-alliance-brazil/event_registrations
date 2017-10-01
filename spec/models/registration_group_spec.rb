describe RegistrationGroup, type: :model do
  let(:event) { FactoryGirl.create :event }
  let(:group) { FactoryGirl.create :registration_group, event: event }

  context 'associations' do
    it { is_expected.to have_many :attendances }
    it { is_expected.to have_many :invoices }

    it { is_expected.to belong_to :event }
    it { is_expected.to belong_to(:leader).class_name('User') }
    it { is_expected.to belong_to(:registration_quota) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :event }
    it { is_expected.to validate_presence_of :name }

    context 'paid_in_advance group validation' do
      context 'when is a paid_in_advance group' do
        subject(:group) { FactoryGirl.build(:registration_group, paid_in_advance: true) }
        it 'not be valid and will have errors on capacity and amount presence' do
          expect(group.valid?).to be_falsey
          expect(group.errors.full_messages).to eq ['Capacidade não pode ficar em branco', 'Valor das inscrições no grupo não pode ficar em branco']
        end
      end
      context 'when is not a paid_in_advance group' do
        subject(:group) { FactoryGirl.build(:registration_group, paid_in_advance: false) }
        it { expect(group.valid?).to be_truthy }
      end
    end

    context '#enough_capacity' do
      context 'for event' do
        let(:event) { FactoryGirl.create :event, attendance_limit: 5 }
        let(:group) { FactoryGirl.build :registration_group, event: event, paid_in_advance: true, capacity: 10, amount: 100 }
        it 'not consider the group as valid and gives the correct error message' do
          expect(group.valid?).to be_falsey
          expect(group.errors.full_messages).to eq ['Capacidade O evento não tem mais lugares para o seu grupo. Desculpe!']
        end
      end
      context 'for quota' do
        let(:quota) { FactoryGirl.create :registration_quota, quota: 5 }
        let(:group) { FactoryGirl.build :registration_group, registration_quota: quota, paid_in_advance: true, capacity: 10, amount: 100 }
        it 'not consider the group as valid and gives the correct error message' do
          expect(group.valid?).to be_falsey
          expect(group.errors.full_messages).to eq ['Capacidade A cota não tem mais lugares para o seu grupo. Desculpe!']
        end
      end
    end
  end

  describe '#destroy' do
    context 'mark attendances as cancelled' do
      before do
        2.times { FactoryGirl.create :attendance, registration_group: group }
        @attendances = Attendance.where(registration_group: group.id).all.to_a
        group.destroy
      end
      it { expect(RegistrationGroup.all).not_to include(group) }
      it { expect(@attendances.map(&:reload).map(&:status).uniq).to eq(['cancelled']) }
    end
  end

  describe '#generate_token' do
    let(:event) { FactoryGirl.create :event }
    let(:group) { FactoryGirl.create :registration_group, event: event }
    before { SecureRandom.expects(:hex).returns('eb693ec8252cd630102fd0d0fb7c3485') }
    it { expect(group.token).to eq 'eb693ec8252cd630102fd0d0fb7c3485' }
  end

  describe '#qtd_attendances' do
    context 'just pending attendances' do
      let(:group) { FactoryGirl.create :registration_group, event: event }
      before { 2.times { FactoryGirl.create :attendance, registration_group: group } }
      it { expect(group.qtd_attendances).to eq 2 }
    end

    context 'with cancelled attendances' do
      let(:group) { FactoryGirl.create :registration_group, event: event }
      before do
        2.times { @last_attendance = FactoryGirl.create(:attendance, registration_group: group) }
        @last_attendance.cancel
      end
      it { expect(group.qtd_attendances).to eq 1 }
    end
  end

  describe '#total_price' do
    let(:group) { FactoryGirl.create :registration_group, event: event }

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
    let!(:period) { RegistrationPeriod.create(event: event, start_at: 1.month.ago, end_at: 1.month.from_now, price: 100) }
    let(:group) { FactoryGirl.create :registration_group, event: event, discount: 20 }

    context 'without attendances' do
      it { expect(group.price?).to be_falsey }
    end

    context 'with attendances' do
      context 'and no value' do
        let(:group) { FactoryGirl.create :registration_group, event: event }
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
    let(:group) { FactoryGirl.create :registration_group, event: event, discount: 100 }
    context 'with a pending invoice' do
      let!(:invoice) { FactoryGirl.create :invoice, invoiceable: group, amount: 100.00 }
      it 'will change the invoice amount' do
        group.stubs(:total_price).returns 200.00
        group.update_invoice
        expect(Invoice.last.amount).to eq 200.00
      end
    end

    context 'with a not pending invoice' do
      let!(:invoice) { FactoryGirl.create :invoice, invoiceable: group, amount: 100.00, status: Invoice::PAID }
      it 'will not change the invoice amount' do
        group.stubs(:total_price).returns 200.00
        group.update_invoice
        expect(Invoice.last.amount).to eq 100.00
      end
    end
  end

  describe '#update_invoice' do
    let(:group) { FactoryGirl.create :registration_group, event: event, discount: 100 }
    context 'with a pending invoice' do
      let!(:invoice) { FactoryGirl.create :invoice, invoiceable: group, amount: 100.00 }
      it 'will change the invoice amount' do
        group.stubs(:total_price).returns 200.00
        group.update_invoice
        expect(Invoice.last.amount).to eq 200.00
      end
    end

    context 'with a not pending invoice' do
      let!(:invoice) { FactoryGirl.create :invoice, invoiceable: group, amount: 100.00, status: Invoice::PAID }
      it 'will not change the invoice amount' do
        group.stubs(:total_price).returns 200.00
        group.update_invoice
        expect(Invoice.last.amount).to eq 100.00
      end
    end
  end

  describe '#accept_members?' do
    let(:group) { FactoryGirl.create :registration_group, event: event, discount: 100 }

    context 'with a pending invoice' do
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group, status: 'pending') }
      it { expect(group.accept_members?).to be_truthy }
    end
  end

  describe '#payment_pendent?' do
    context 'consistent data' do
      context 'with one pendent' do
        let(:group) { FactoryGirl.create :registration_group, event: event, discount: 20 }
        let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group, status: 'pending') }
        it { expect(group.paid?).to be_falsey }
      end

      context 'with one paid' do
        let(:group) { FactoryGirl.create :registration_group, event: event, discount: 20 }
        let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group, status: 'paid') }
        it { expect(group.paid?).to be_truthy }
      end
    end

    context 'with inconsistent data' do
      context 'with one paid and one pendent' do
        let(:group) { FactoryGirl.create :registration_group, event: event, discount: 20 }
        let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group, status: 'paid') }
        let!(:other_attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group, status: 'pending') }
        it { expect(group.paid?).to be_truthy }
      end
    end
  end

  describe '#leader_name' do
    let(:user) { FactoryGirl.create :user }
    context 'with a defined leader' do
      let(:group) { FactoryGirl.create :registration_group, event: event, discount: 20, leader: user }
      it { expect(group.leader_name).to eq user.full_name }
    end

    context 'with a defined leader' do
      let(:group) { FactoryGirl.create :registration_group, event: event }
      it { expect(group.leader_name).to eq nil }
    end
  end

  describe '#free?' do
    context 'with a free' do
      let(:group) { FactoryGirl.create(:registration_group, event: event, discount: 100) }
      it { expect(group.free?).to be_truthy }
    end

    context 'with a non free' do
      let(:group) { FactoryGirl.create(:registration_group, event: event, discount: 99) }
      it { expect(group.free?).to be_falsey }
    end
  end

  describe '#floor?' do
    context 'with minimun_size nil' do
      let(:group) { FactoryGirl.create(:registration_group, minimum_size: nil) }
      it { expect(group.floor?).to be_falsey }
    end

    context 'with minimun_size 0' do
      let(:group) { FactoryGirl.create(:registration_group, minimum_size: 0) }
      it { expect(group.floor?).to be_falsey }
    end

    context 'with minimun_size 1' do
      let(:group) { FactoryGirl.create(:registration_group, minimum_size: 1) }
      it { expect(group.floor?).to be_falsey }
    end

    context 'with minimun_size 2' do
      let(:group) { FactoryGirl.create(:registration_group, minimum_size: 2) }
      it { expect(group.floor?).to be_truthy }
    end

    context 'with minimun_size greather than 2' do
      let(:group) { FactoryGirl.create(:registration_group, minimum_size: 10) }
      it { expect(group.floor?).to be_truthy }
    end
  end

  describe '#incomplete?' do
    context 'with nil minimun_size' do
      let(:group) { FactoryGirl.create(:registration_group, minimum_size: nil) }
      it { expect(group.incomplete?).to be_falsey }
    end

    context 'with minimun_size of 0' do
      let(:group) { FactoryGirl.create(:registration_group, minimum_size: 0) }
      it { expect(group.incomplete?).to be_falsey }
    end

    context 'with minimum size of 1' do
      let(:group) { FactoryGirl.create(:registration_group, minimum_size: 1) }
      context 'and one attendance pending' do
        let!(:attendance) { FactoryGirl.create(:attendance, registration_group: group, status: 'pending') }
        it { expect(group.incomplete?).to be_truthy }
      end
      context 'and one attendance accepted' do
        let!(:attendance) { FactoryGirl.create(:attendance, registration_group: group, status: 'accepted') }
        it { expect(group.incomplete?).to be_truthy }
      end
      context 'and one attendance paid' do
        let!(:attendance) { FactoryGirl.create(:attendance, registration_group: group, status: 'paid') }
        it { expect(group.incomplete?).to be_falsey }
      end
      context 'and one attendance confirmed' do
        let!(:attendance) { FactoryGirl.create(:attendance, registration_group: group, status: 'confirmed') }
        it { expect(group.incomplete?).to be_falsey }
      end
    end

    context 'with minimun_size of 2' do
      let(:group) { FactoryGirl.create(:registration_group, minimum_size: 2) }
      context 'and two attendances pending' do
        let!(:attendance) { FactoryGirl.create(:attendance, registration_group: group, status: 'pending') }
        let!(:other_attendance) { FactoryGirl.create(:attendance, registration_group: group, status: 'pending') }
        it { expect(group.incomplete?).to be_truthy }
      end
      context 'and one attendance paid and other pending' do
        let!(:attendance) { FactoryGirl.create(:attendance, registration_group: group, status: 'paid') }
        let!(:other_attendance) { FactoryGirl.create(:attendance, registration_group: group, status: 'pending') }
        it { expect(group.incomplete?).to be_truthy }
      end
      context 'and one attendance paid and other accepted' do
        let!(:attendance) { FactoryGirl.create(:attendance, registration_group: group, status: 'paid') }
        let!(:other_attendance) { FactoryGirl.create(:attendance, registration_group: group, status: 'accepted') }
        it { expect(group.incomplete?).to be_truthy }
      end
      context 'and two attendances paid' do
        let!(:attendance) { FactoryGirl.create(:attendance, registration_group: group, status: 'paid') }
        let!(:other_attendance) { FactoryGirl.create(:attendance, registration_group: group, status: 'paid') }
        it { expect(group.incomplete?).to be_falsey }
      end
      context 'and one attendance paid and other confirmed' do
        let!(:attendance) { FactoryGirl.create(:attendance, registration_group: group, status: 'paid') }
        let!(:other_attendance) { FactoryGirl.create(:attendance, registration_group: group, status: 'confirmed') }
        it { expect(group.incomplete?).to be_falsey }
      end
    end
  end

  describe '#to_s' do
    let(:group) { FactoryGirl.create :registration_group }
    it { expect(group.to_s).to eq group.name }
  end

  describe '#capacity_left' do
    context 'having capacity' do
      let(:group) { FactoryGirl.create :registration_group, capacity: 100 }
      let!(:attendance) { FactoryGirl.create :attendance, registration_group: group }
      let!(:other_attendance) { FactoryGirl.create :attendance, registration_group: group, status: :cancelled }
      it { expect(group.capacity_left).to eq 99 }
    end
    context 'having no capacity' do
      let(:group) { FactoryGirl.create :registration_group, capacity: nil }
      let!(:attendance) { FactoryGirl.create :attendance, registration_group: group }
      let!(:other_attendance) { FactoryGirl.create :attendance, registration_group: group, status: :cancelled }
      it { expect(group.capacity_left).to eq 0 }
    end
  end

  describe '#vacancies?' do
    context 'having vacancies' do
      let(:group) { FactoryGirl.create :registration_group, capacity: 3 }
      let!(:attendance) { FactoryGirl.create :attendance, registration_group: group }
      let!(:other_attendance) { FactoryGirl.create :attendance, registration_group: group, status: :accepted }
      let!(:cancelled_attendance) { FactoryGirl.create :attendance, registration_group: group, status: :cancelled }

      it { expect(group.vacancies?).to eq true }
    end
    context 'having no vacancies' do
      let(:group) { FactoryGirl.create :registration_group, capacity: 2 }
      let!(:attendance) { FactoryGirl.create :attendance, registration_group: group }
      let!(:other_attendance) { FactoryGirl.create :attendance, registration_group: group, status: :accepted }
      let!(:cancelled_attendance) { FactoryGirl.create :attendance, registration_group: group, status: :cancelled }
      it { expect(group.vacancies?).to eq false }
    end
    context 'having no capacity defined' do
      let(:group) { FactoryGirl.create :registration_group, capacity: nil }
      it { expect(group.vacancies?).to be true }
    end
  end
end
