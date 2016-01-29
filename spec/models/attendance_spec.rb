describe Attendance, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :event }
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :registration_group }
    it { is_expected.to belong_to :registration_quota }
    it { is_expected.to have_many(:invoices) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :first_name }
    it { is_expected.to validate_presence_of :last_name }
    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_presence_of :phone }
    it { is_expected.to validate_presence_of :country }
    it { is_expected.to validate_presence_of :city }

    it { is_expected.to allow_value('1234-2345').for(:phone) }
    it { is_expected.to allow_value('+55 11 5555 2234').for(:phone) }
    it { is_expected.to allow_value('+1 (304) 543.3333').for(:phone) }
    it { is_expected.to allow_value('07753423456').for(:phone) }
    it { is_expected.not_to allow_value('a').for(:phone) }
    it { is_expected.not_to allow_value('1234-bfd').for(:phone) }
    it { is_expected.not_to allow_value(')(*&^%$@!').for(:phone) }
    it { is_expected.not_to allow_value('[=+]').for(:phone) }

    context 'brazilians' do
      subject { FactoryGirl.build(:attendance, country: 'BR') }
      it { is_expected.to validate_presence_of :state }
      it { is_expected.to validate_presence_of :cpf }
    end

    context 'foreigners' do
      subject { FactoryGirl.build(:attendance, country: 'US') }
      it { is_expected.not_to validate_presence_of :state }
      it { is_expected.not_to validate_presence_of :cpf }
    end

    it { is_expected.to validate_length_of(:email).is_at_least(6).is_at_most(100) }
    it { is_expected.to validate_length_of(:first_name).is_at_most(100) }
    it { is_expected.to validate_length_of(:last_name).is_at_most(100) }
    it { is_expected.to validate_length_of(:city).is_at_most(100) }
    it { is_expected.to validate_length_of(:organization).is_at_most(100) }

    it { is_expected.to allow_value('user@domain.com.br').for(:email) }
    it { is_expected.to allow_value('test_user.name@a.co.uk').for(:email) }
    it { is_expected.not_to allow_value('a').for(:email) }
    it { is_expected.not_to allow_value('a@').for(:email) }
    it { is_expected.not_to allow_value('a@a').for(:email) }
    it { is_expected.not_to allow_value('@12.com').for(:email) }
  end

  context 'callbacks' do
    let!(:event) { FactoryGirl.create :event }
    describe '#update_group_invoice' do
      context 'having a registration group' do
        let(:group) { RegistrationGroup.create! event: event }
        let!(:invoice) { FactoryGirl.create :invoice, invoiceable: group, amount: 50.00 }
        it 'updates the group invoice when add attendace to the group' do
          RegistrationGroup.any_instance.expects(:update_invoice).once
          FactoryGirl.create(:attendance, registration_group: group, registration_value: 100)
        end
      end

      context 'without a registration group' do
        it 'updates the group invoice when add attendace to the group' do
          RegistrationGroup.any_instance.expects(:update_invoice).never
          FactoryGirl.create(:attendance, registration_value: 100)
        end
      end
    end
  end

  context 'scopes' do
    context 'with five attendances created' do
      before { 5.times { FactoryGirl.create(:attendance) } }

      it { expect(Attendance.for_event(Attendance.first.event)).to eq([Attendance.first]) }
      it { expect(Attendance.pending).to include(Attendance.first) }

      it 'has scope accepted' do
        Attendance.first.tap(&:accept).save
        expect(Attendance.accepted).to include Attendance.first
      end

      it 'has scope paid' do
        Attendance.first.tap(&:pay).save
        expect(Attendance.paid).to eq([Attendance.first])
      end

      it 'has scope active that excludes cancelled attendances' do
        Attendance.first.tap(&:cancel).save
        expect(Attendance.active).not_to include(Attendance.first)
      end

      it 'has scope older_than that selects old attendances' do
        Attendance.first.tap { |a| a.registration_date = 10.days.ago }.save
        expect(Attendance.older_than(5.days.ago)).to eq([Attendance.first])
      end
    end

    context 'with specific seed' do
      describe '.active' do
        let!(:pending) { FactoryGirl.create(:attendance, status: :pending) }
        let!(:accepted) { FactoryGirl.create(:attendance, status: :accepted) }
        let!(:paid) { FactoryGirl.create(:attendance, status: :paid) }
        let!(:confirmed) { FactoryGirl.create(:attendance, status: :confirmed) }
        let!(:cancelled) { FactoryGirl.create(:attendance, status: :cancelled) }
        let!(:no_show) { FactoryGirl.create(:attendance, status: :no_show) }
        it { expect(Attendance.active).to eq [pending, accepted, paid, confirmed] }
      end

      describe '.last_biweekly_active' do
        let!(:last_week) { FactoryGirl.create(:attendance, created_at: 7.days.ago) }
        let!(:other_last_week) { FactoryGirl.create(:attendance, created_at: 7.days.ago) }
        let!(:today) { FactoryGirl.create(:attendance) }
        let!(:out) { FactoryGirl.create(:attendance, created_at: 21.days.ago) }

        it { expect(Attendance.last_biweekly_active).to eq [last_week, other_last_week, today] }
      end

      describe '.waiting_approval' do
        let(:group) { FactoryGirl.create(:registration_group) }
        let!(:pending) { FactoryGirl.create(:attendance, registration_group: group, status: :pending) }
        let!(:out_pending) { FactoryGirl.create(:attendance, status: :pending) }
        let!(:accepted) { FactoryGirl.create(:attendance, registration_group: group, status: :accepted) }
        let!(:paid) { FactoryGirl.create(:attendance, registration_group: group, status: :paid) }
        let!(:confirmed) { FactoryGirl.create(:attendance, registration_group: group, status: :confirmed) }
        it { expect(Attendance.waiting_approval).to eq [pending] }
      end

      describe '.pending_accepted' do
        let!(:pending) { FactoryGirl.create(:attendance, status: :pending) }
        let!(:accepted) { FactoryGirl.create(:attendance, status: :accepted) }
        let!(:paid) { FactoryGirl.create(:attendance, status: :paid) }
        let!(:confirmed) { FactoryGirl.create(:attendance, status: :confirmed) }
        let!(:cancelled) { FactoryGirl.create(:attendance, status: :cancelled) }
        it { expect(Attendance.pending_accepted).to eq [pending, accepted] }
      end

      describe '.already_paid' do
        let!(:pending) { FactoryGirl.create(:attendance, status: :pending) }
        let!(:accepted) { FactoryGirl.create(:attendance, status: :accepted) }
        let!(:paid) { FactoryGirl.create(:attendance, status: :paid) }
        let!(:confirmed) { FactoryGirl.create(:attendance, status: :confirmed) }
        let!(:cancelled) { FactoryGirl.create(:attendance, status: :cancelled) }
        it { expect(Attendance.already_paid).to eq [paid, confirmed] }
      end

      describe '.non_free' do
        let!(:pending) { FactoryGirl.create(:attendance, status: :pending, registration_value: 100) }
        let!(:accepted) { FactoryGirl.create(:attendance, status: :accepted, registration_value: 0) }
        it { expect(Attendance.non_free).to eq [pending] }
      end

      describe '.pending' do
        let!(:pending) { FactoryGirl.create(:attendance, status: :pending) }
        let!(:accepted) { FactoryGirl.create(:attendance, status: :accepted) }
        let!(:paid) { FactoryGirl.create(:attendance, status: :paid) }
        let!(:confirmed) { FactoryGirl.create(:attendance, status: :confirmed) }
        let!(:cancelled) { FactoryGirl.create(:attendance, status: :cancelled) }
        it { expect(Attendance.pending).to eq [pending, accepted] }
      end
    end
  end

  context 'state machine' do
    it 'starts pending' do
      attendance = Attendance.new
      expect(attendance.status).to eq 'pending'
    end

    describe '#pay' do
      context 'when is group member' do
        context 'and the group has a floor' do
          let(:group) { FactoryGirl.create(:registration_group, minimum_size: 10) }

          context 'from pending' do
            let(:attendance) { FactoryGirl.create(:attendance, registration_group: group) }
            context 'without invoice' do
              it 'move to paid upon payment' do
                attendance.pay
                expect(attendance.status).to eq 'paid'
              end
            end

            context 'with an invoice' do
              it 'move both attendance and invoice to paid upon payment' do
                Invoice.from_attendance(attendance, Invoice::GATEWAY)
                attendance.pay
                expect(attendance.status).to eq 'paid'
                expect(Invoice.last.status).to eq 'paid'
              end
            end
          end

          context 'from accepted' do
            it 'move to paid upon payment' do
              attendance = FactoryGirl.create :attendance, status: 'accepted', registration_group: group
              attendance.pay
              expect(attendance.status).to eq 'paid'
            end
          end

          context 'from cancelled' do
            it 'stay cancelled' do
              attendance = FactoryGirl.create :attendance, status: 'cancelled', registration_group: group
              attendance.pay
              expect(attendance.status).to eq 'cancelled'
            end
          end
        end

        context 'and the group having no floor' do
          let(:group) { FactoryGirl.create(:registration_group, minimum_size: 1) }

          context 'from pending' do
            let(:attendance) { FactoryGirl.create(:attendance, registration_group: group) }
            context 'without invoice' do
              it 'move to paid upon payment' do
                EmailNotifications.expects(:registration_confirmed).once
                attendance.pay
                expect { attendance.pay }.not_to raise_error
                expect(attendance.status).to eq 'confirmed'
              end
            end

            context 'with an invoice' do
              it 'move both attendance and invoice to paid upon payment' do
                EmailNotifications.expects(:registration_confirmed).once
                Invoice.from_attendance(attendance, Invoice::GATEWAY)
                attendance.pay
                expect(attendance.status).to eq 'confirmed'
                expect(Invoice.last.status).to eq 'paid'
              end
            end
          end
        end
      end
    end

    describe '#cancel' do
      context 'when is pending' do
        it 'cancel the attendance and the invoice' do
          attendance = FactoryGirl.create :attendance

          attendance.cancel
          expect(attendance.status).to eq 'cancelled'
        end
      end

      context 'when is accepted' do
        it 'cancel the attendance' do
          attendance = FactoryGirl.create :attendance, status: 'accepted'
          attendance.cancel
          expect(attendance.status).to eq 'cancelled'
        end
      end

      context 'when is confirmed' do
        it 'cancel the attendance' do
          attendance = FactoryGirl.create :attendance, status: 'confirmed'
          attendance.cancel
          expect(attendance.status).to eq 'cancelled'
        end
      end

      context 'when is paid' do
        it 'cancel the attendance' do
          attendance = FactoryGirl.create :attendance, status: 'paid'
          attendance.cancel
          expect(attendance.status).to eq 'cancelled'
        end
      end
    end

    describe '#accept' do
      context 'when is pending' do
        it 'accept the attendance' do
          EmailNotifications.expects(:registration_group_accepted).once
          attendance = FactoryGirl.create :attendance
          attendance.accept
          expect(attendance.status).to eq 'accepted'
        end
      end

      context 'when is cancelled' do
        it 'keep it cancelled' do
          EmailNotifications.expects(:registration_group_accepted).never
          attendance = FactoryGirl.create :attendance, status: :cancelled
          attendance.accept
          expect(attendance.status).to eq 'cancelled'
        end
      end

      context 'when is paid' do
        it 'keep it paid' do
          EmailNotifications.expects(:registration_group_accepted).never
          attendance = FactoryGirl.create :attendance, status: :paid
          attendance.accept
          expect(attendance.status).to eq 'paid'
        end
      end

      context 'when is already accepted' do
        it 'keep it accepted' do
          EmailNotifications.expects(:registration_group_accepted).never
          attendance = FactoryGirl.create :attendance, status: :accepted
          attendance.accept
          expect(attendance.status).to eq 'accepted'
        end
      end

      context 'when belongs to a free group' do
        it 'confirms' do
          EmailNotifications.expects(:registration_group_accepted).never
          group = FactoryGirl.create :registration_group, discount: 100
          attendance = FactoryGirl.create :attendance, status: :pending, registration_group: group
          attendance.accept
          expect(attendance.status).to eq 'confirmed'
        end
      end
    end

    describe '#confirm' do
      context 'when is pending' do
        it 'confirm the attendance' do
          EmailNotifications.expects(:registration_confirmed).once
          attendance = FactoryGirl.create :attendance
          Invoice.from_attendance(attendance, Invoice::GATEWAY)
          attendance.confirm
          expect(attendance.status).to eq 'confirmed'
          expect(Invoice.last.status).to eq 'paid'
        end
      end

      context 'when is accepted' do
        it 'confirm the attendance' do
          EmailNotifications.expects(:registration_confirmed).once
          attendance = FactoryGirl.create :attendance, status: :accepted
          attendance.confirm
          expect(attendance.status).to eq 'confirmed'
        end
      end

      context 'when is cancelled' do
        it 'keep it cancelled' do
          EmailNotifications.expects(:registration_confirmed).never
          attendance = FactoryGirl.create :attendance, status: :cancelled
          attendance.confirm
          expect(attendance.status).to eq 'cancelled'
        end
      end

      context 'when is paid' do
        it 'keep it paid' do
          EmailNotifications.expects(:registration_confirmed).once
          attendance = FactoryGirl.create :attendance, status: :paid
          attendance.confirm
          expect(attendance.status).to eq 'confirmed'
        end
      end
    end

    describe '#mark_no_show' do
      context 'when is pending' do
        it 'mark as no show' do
          attendance = FactoryGirl.create :attendance
          attendance.expects(:cancel_invoice!).once
          attendance.mark_no_show
          expect(attendance.status).to eq 'no_show'
        end
      end

      context 'when is accepted' do
        it 'mark as no show' do
          attendance = FactoryGirl.create :attendance, status: :accepted
          attendance.expects(:cancel_invoice!).once
          attendance.mark_no_show
          expect(attendance.status).to eq 'no_show'
        end
      end

      context 'when is cancelled' do
        it 'keep it cancelled' do
          attendance = FactoryGirl.create :attendance, status: :cancelled
          attendance.expects(:cancel_invoice!).never
          attendance.mark_no_show
          expect(attendance.status).to eq 'cancelled'
        end
      end

      context 'when is paid' do
        it 'keep it paid' do
          attendance = FactoryGirl.create :attendance, status: :paid
          attendance.expects(:cancel_invoice!).never
          attendance.mark_no_show
          expect(attendance.status).to eq 'paid'
        end
      end

      context 'when is confirmed' do
        it 'keep it paid' do
          attendance = FactoryGirl.create :attendance, status: :confirmed
          attendance.expects(:cancel_invoice!).never
          attendance.mark_no_show
          expect(attendance.status).to eq 'confirmed'
        end
      end
    end
  end

  describe '#cancellable?' do
    let(:attendance) { FactoryGirl.build(:attendance) }
    context 'when is pending' do
      it { expect(attendance).to be_cancellable }
    end

    context 'when is accepted' do
      before { attendance.accept }
      it { expect(attendance).to be_cancellable }
    end

    context 'when is paid' do
      before { attendance.pay }
      it { expect(attendance).to be_cancellable }
    end

    context 'when is confirmed' do
      before do
        attendance.pay
        attendance.confirm
      end
      it { expect(attendance).to be_cancellable }
    end

    context 'when is already cancelled' do
      before { attendance.cancel }
      it { expect(attendance).not_to be_cancellable }
    end
  end

  describe '#transferrable?' do
    let(:attendance) { FactoryGirl.build(:attendance) }
    context 'when is pending' do
      it { expect(attendance).not_to be_transferrable }
    end

    context 'when is accepted' do
      before { attendance.accept }
      it { expect(attendance).not_to be_transferrable }
    end

    context 'when is paid' do
      before { attendance.pay }
      it { expect(attendance).to be_transferrable }
    end

    context 'when is confirmed' do
      before do
        attendance.pay
        attendance.confirm
      end
      it { expect(attendance).to be_transferrable }
    end
  end

  describe '#confirmable?' do
    let(:attendance) { FactoryGirl.build(:attendance) }
    context 'when is pending' do
      it { expect(attendance).to be_confirmable }
    end

    context 'when is accepted' do
      before { attendance.accept }
      it { expect(attendance).to be_confirmable }
    end

    context 'when is paid' do
      context 'and grouped' do
        let(:group) { FactoryGirl.create(:registration_group) }
        let(:grouped_attendance) { FactoryGirl.create(:attendance, registration_group: group) }
        before { grouped_attendance.pay }
        it { expect(grouped_attendance).to be_confirmable }
      end

      context 'and individual the attendance is automatically confirmed' do
        before { attendance.pay }
        it { expect(attendance).not_to be_confirmable }
      end
    end

    context 'when it is already confirmed' do
      before do
        attendance.pay
        attendance.confirm
      end
      it { expect(attendance).not_to be_confirmable }
    end
  end

  describe '#recoverable?' do
    let(:attendance) { FactoryGirl.build(:attendance) }
    context 'when is pending' do
      it { expect(attendance).not_to be_recoverable }
    end

    context 'when it is accepted' do
      before { attendance.accept }
      it { expect(attendance).not_to be_recoverable }
    end

    context 'when it is paid' do
      before { attendance.pay }
      it { expect(attendance).not_to be_recoverable }
    end

    context 'when it is cancelled' do
      before { attendance.cancel }
      it { expect(attendance).to be_recoverable }
    end
  end

  describe '#payable?' do
    let(:attendance) { FactoryGirl.build(:attendance) }
    context 'when is pending' do
      it { expect(attendance).to be_payable }
    end

    context 'when it is accepted' do
      before { attendance.accept }
      it { expect(attendance).to be_payable }
    end

    context 'when it is paid' do
      before { attendance.pay }
      it { expect(attendance).not_to be_payable }
    end

    context 'when it is cancelled' do
      before { attendance.cancel }
      it { expect(attendance).not_to be_payable }
    end

    context 'when it is confirmed' do
      before { attendance.confirm }
      it { expect(attendance).not_to be_payable }
    end
  end

  describe '#discount' do
    let(:event) { FactoryGirl.create(:event) }
    context 'when is not member of a group' do
      let!(:attendance) { FactoryGirl.create(:attendance, event: event) }
      it { expect(attendance.discount).to eq 1 }
    end

    context 'when is member of a 30% group' do
      let(:group) { FactoryGirl.create(:registration_group, event: event, discount: 30) }
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group) }
      it { expect(attendance.discount).to eq 0.7 }
    end

    context 'when is member of a 100% group' do
      let(:group) { FactoryGirl.create(:registration_group, event: event, discount: 100) }
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group) }
      it { expect(attendance.discount).to eq 0 }
    end
  end

  describe '#group_name' do
    let(:event) { FactoryGirl.create(:event) }
    context 'with a registration group' do
      let!(:group) { FactoryGirl.create :registration_group, event: event }
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group) }
      it { expect(attendance.group_name).to eq group.name }
    end

    context 'with no registration group' do
      let!(:attendance) { FactoryGirl.create(:attendance, event: event) }
      it { expect(attendance.group_name).to eq nil }
    end
  end

  describe '#event_name' do
    context 'with an event' do
      let(:event) { FactoryGirl.create(:event) }
      let!(:attendance) { FactoryGirl.create(:attendance, event: event) }
      it { expect(attendance.event_name).to eq event.name }
    end
  end

  describe '#grouped?' do
    let(:event) { FactoryGirl.create(:event) }

    context 'when belongs to a group' do
      let(:group) { RegistrationGroup.create! event: event }
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group) }

      it { expect(attendance.grouped?).to be_truthy }
    end

    context 'when not belonging to a group' do
      let!(:attendance) { FactoryGirl.create(:attendance, event: event) }

      it { expect(attendance.grouped?).to be_falsey }
    end
  end

  describe '#advise!' do
    context 'with a valid attendance' do
      let(:event) { FactoryGirl.create :event }
      let!(:attendance) { FactoryGirl.create(:attendance, event: event) }
      before { attendance.advise! }
      it { expect(Attendance.last.advised).to be_truthy }
      it { expect(Attendance.last.advised_at).to be_within(30.seconds).of Time.zone.now }
    end
  end

  describe '.to_csv' do
    context 'with attendances' do
      let(:event) { FactoryGirl.create :event }
      let(:group) { FactoryGirl.create :registration_group, event: event, name: 'Group for to csv test' }
      let!(:attendance) do
        FactoryGirl.create(:attendance,
                           event: event,
                           status: :pending,
                           first_name: 'bLa',
                           registration_group: group)
      end

      let(:expected) do
        title = "first_name,last_name,organization,email,payment_type,group_name,city,state,value\n"
        body =
          "#{attendance.first_name},"\
          "#{attendance.last_name},"\
          "#{attendance.organization},"\
          "#{attendance.email},"\
          "#{attendance.payment_type},"\
          "#{attendance.group_name},"\
          "#{attendance.city},"\
          "#{attendance.state},"\
          "#{attendance.registration_value}\n"
        title + body
      end
      subject(:attendances_list) { Attendance.all }
      it { expect(attendances_list.to_csv).to eq expected }
    end
  end

  describe '#due_date' do
    context 'when the attendance was not advised yet' do
      let(:event) { FactoryGirl.create(:event, start_date: 3.days.from_now) }
      let(:attendance) { FactoryGirl.create(:attendance, event: event, advised_at: nil) }
      it { expect(attendance.due_date.to_date).to eq event.start_date.to_date }
    end

    context 'when event start date is after event due date' do
      let(:event) { FactoryGirl.create(:event, start_date: 3.days.from_now) }
      let(:attendance) { FactoryGirl.create(:attendance, event: event, advised_at: 7.days.ago) }
      it { expect(attendance.due_date.to_date).to eq Time.zone.today }
    end

    context 'when event start date is before event due date' do
      let(:event) { FactoryGirl.create(:event, start_date: 3.days.from_now) }
      let(:attendance) { FactoryGirl.create(:attendance, event: event, advised_at: Time.zone.today) }
      it { expect(attendance.due_date.to_date).to eq event.start_date.to_date }
    end
  end

  context 'delegates' do
    describe '#token' do
      let(:group) { FactoryGirl.create :registration_group }
      let(:attendance) { FactoryGirl.create :attendance, registration_group: group }

      it { expect(attendance.token).to eq group.token }
      it { expect(attendance.group_name).to eq group.name }
      it { expect(attendance.event_name).to eq attendance.event.name }
    end
  end

  describe '#to_s' do
    let(:attendance) { FactoryGirl.create :attendance, first_name: 'foo', last_name: 'bar' }
    it { expect(attendance.to_s).to eq 'bar, foo' }
  end
end
