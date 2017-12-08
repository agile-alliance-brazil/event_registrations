RSpec.describe Attendance, type: :model do
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
    it { is_expected.to validate_presence_of :user }
    it { is_expected.to validate_presence_of :event }

    it { is_expected.to allow_value('1234-2345').for(:phone) }
    it { is_expected.to allow_value('+55 11 5555 2234').for(:phone) }
    it { is_expected.to allow_value('+1 (304) 543.3333').for(:phone) }
    it { is_expected.to allow_value('07753423456').for(:phone) }
    it { is_expected.not_to allow_value('a').for(:phone) }
    it { is_expected.not_to allow_value('1234-bfd').for(:phone) }
    it { is_expected.not_to allow_value(')(*&^%$@!').for(:phone) }
    it { is_expected.not_to allow_value('[=+]').for(:phone) }
    it { is_expected.to validate_presence_of :state }

    context 'brazilians' do
      subject { FactoryBot.build(:attendance, country: 'BR') }
      it { is_expected.to validate_presence_of :cpf }
    end

    context 'foreigners' do
      subject { FactoryBot.build(:attendance, country: 'US') }
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

  context 'enums' do
    it { is_expected.to define_enum_for(:job_role).with(%i[not_informed student analyst manager vp president clevel coach other developer]) }
  end

  context 'callbacks' do
    let!(:event) { FactoryBot.create :event }
    describe '#update_group_invoice' do
      context 'having a registration group' do
        let(:group) { FactoryBot.create :registration_group, event: event }
        let!(:invoice) { FactoryBot.create :invoice, invoiceable: group, amount: 50.00 }
        it 'updates the group invoice when add attendace to the group' do
          RegistrationGroup.any_instance.expects(:update_invoice).once
          FactoryBot.create(:attendance, registration_group: group, registration_value: 100)
        end
      end

      context 'without a registration group' do
        it 'updates the group invoice when add attendace to the group' do
          RegistrationGroup.any_instance.expects(:update_invoice).never
          FactoryBot.create(:attendance, registration_value: 100)
        end
      end
    end
  end

  context 'scopes' do
    context 'with five attendances created' do
      before { 5.times { FactoryBot.create(:attendance) } }

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
    end

    context 'with specific seed' do
      describe '.active' do
        let!(:pending) { FactoryBot.create(:attendance, status: :pending) }
        let!(:accepted) { FactoryBot.create(:attendance, status: :accepted) }
        let!(:paid) { FactoryBot.create(:attendance, status: :paid) }
        let!(:confirmed) { FactoryBot.create(:attendance, status: :confirmed) }
        let!(:cancelled) { FactoryBot.create(:attendance, status: :cancelled) }
        let!(:no_show) { FactoryBot.create(:attendance, status: :no_show) }
        let!(:waiting) { FactoryBot.create(:attendance, status: :waiting) }
        it { expect(Attendance.active).to eq [pending, accepted, paid, confirmed] }
      end

      describe '.last_biweekly_active' do
        let!(:last_week) { FactoryBot.create(:attendance, created_at: 7.days.ago) }
        let!(:other_last_week) { FactoryBot.create(:attendance, created_at: 7.days.ago) }
        let!(:today) { FactoryBot.create(:attendance) }
        let!(:out) { FactoryBot.create(:attendance, created_at: 21.days.ago) }

        it { expect(Attendance.last_biweekly_active).to eq [last_week, other_last_week, today] }
      end

      describe '.waiting_approval' do
        let(:group) { FactoryBot.create(:registration_group) }
        let!(:pending) { FactoryBot.create(:attendance, registration_group: group, status: :pending) }
        let!(:out_pending) { FactoryBot.create(:attendance, status: :pending) }
        let!(:accepted) { FactoryBot.create(:attendance, registration_group: group, status: :accepted) }
        let!(:paid) { FactoryBot.create(:attendance, registration_group: group, status: :paid) }
        let!(:confirmed) { FactoryBot.create(:attendance, registration_group: group, status: :confirmed) }
        it { expect(Attendance.waiting_approval).to eq [pending] }
      end

      describe '.already_paid' do
        let!(:pending) { FactoryBot.create(:attendance, status: :pending) }
        let!(:accepted) { FactoryBot.create(:attendance, status: :accepted) }
        let!(:paid) { FactoryBot.create(:attendance, status: :paid) }
        let!(:confirmed) { FactoryBot.create(:attendance, status: :confirmed) }
        let!(:cancelled) { FactoryBot.create(:attendance, status: :cancelled) }
        it { expect(Attendance.already_paid).to eq [paid, confirmed] }
      end

      describe '.non_free' do
        let!(:pending) { FactoryBot.create(:attendance, status: :pending, registration_value: 100) }
        let!(:accepted) { FactoryBot.create(:attendance, status: :accepted, registration_value: 0) }
        it { expect(Attendance.non_free).to eq [pending] }
      end

      describe '.pending' do
        let!(:pending) { FactoryBot.create(:attendance, status: :pending) }
        let!(:accepted) { FactoryBot.create(:attendance, status: :accepted) }
        let!(:paid) { FactoryBot.create(:attendance, status: :paid) }
        let!(:confirmed) { FactoryBot.create(:attendance, status: :confirmed) }
        let!(:cancelled) { FactoryBot.create(:attendance, status: :cancelled) }
        it { expect(Attendance.pending).to eq [pending] }
      end

      describe '.accepted' do
        let!(:pending) { FactoryBot.create(:attendance, status: :pending) }
        let!(:accepted) { FactoryBot.create(:attendance, status: :accepted) }
        let!(:paid) { FactoryBot.create(:attendance, status: :paid) }
        let!(:confirmed) { FactoryBot.create(:attendance, status: :confirmed) }
        let!(:cancelled) { FactoryBot.create(:attendance, status: :cancelled) }
        it { expect(Attendance.accepted).to eq [accepted] }
      end

      describe '.waiting' do
        let!(:waiting) { FactoryBot.create(:attendance, status: :waiting) }
        let!(:pending) { FactoryBot.create(:attendance, status: :pending) }
        let!(:accepted) { FactoryBot.create(:attendance, status: :accepted) }
        let!(:paid) { FactoryBot.create(:attendance, status: :paid) }
        let!(:confirmed) { FactoryBot.create(:attendance, status: :confirmed) }
        let!(:cancelled) { FactoryBot.create(:attendance, status: :cancelled) }
        it { expect(Attendance.waiting).to eq [waiting] }
      end

      describe '.with_time_in_queue' do
        let!(:attendance) { FactoryBot.create :attendance, first_name: 'foo', last_name: 'bar', queue_time: 100 }
        let!(:other_attendance) { FactoryBot.create :attendance, first_name: 'foo', last_name: 'bar', queue_time: 2 }
        let!(:out_attendance) { FactoryBot.create :attendance, first_name: 'foo', last_name: 'bar', queue_time: 0 }
        it { expect(Attendance.with_time_in_queue).to match_array [attendance, other_attendance] }
      end

      describe '.confirmed' do
        let!(:waiting) { FactoryBot.create(:attendance, status: :waiting) }
        let!(:pending) { FactoryBot.create(:attendance, status: :pending) }
        let!(:accepted) { FactoryBot.create(:attendance, status: :accepted) }
        let!(:paid) { FactoryBot.create(:attendance, status: :paid) }
        let!(:confirmed) { FactoryBot.create(:attendance, status: :confirmed) }
        let!(:cancelled) { FactoryBot.create(:attendance, status: :cancelled) }

        it { expect(Attendance.confirmed).to eq [confirmed] }
      end
    end
  end

  context 'state machine' do
    before { Timecop.freeze }
    after { Timecop.return }
    let(:past_status_date_change) { 2.days.ago }

    describe '#pay' do
      context 'when is group member' do
        context 'and the group has a floor' do
          let(:group) { FactoryBot.create(:registration_group, minimum_size: 10) }

          context 'from pending' do
            let(:attendance) { FactoryBot.create(:attendance, registration_group: group, last_status_change_date: past_status_date_change) }
            context 'without invoice' do
              it 'move to paid upon payment' do
                attendance.pay
                expect(attendance.status).to eq 'paid'
                expect(attendance.last_status_change_date.to_i).to eq Time.zone.now.to_i
              end
            end

            context 'with an invoice' do
              it 'move both attendance and invoice to paid upon payment' do
                Invoice.from_attendance(attendance, 'gateway')
                attendance.pay
                expect(attendance.status).to eq 'paid'
                expect(Invoice.last.status).to eq 'paid'
                expect(attendance.last_status_change_date.to_i).to eq Time.zone.now.to_i
              end
            end
          end

          context 'from accepted' do
            it 'move to paid upon payment' do
              attendance = FactoryBot.create :attendance, status: 'accepted', registration_group: group, last_status_change_date: past_status_date_change
              attendance.pay
              expect(attendance.status).to eq 'paid'
              expect(attendance.last_status_change_date.to_i).to eq Time.zone.now.to_i
            end
          end

          context 'from cancelled' do
            it 'stay cancelled' do
              attendance = FactoryBot.create :attendance, status: 'cancelled', registration_group: group, last_status_change_date: past_status_date_change
              attendance.pay
              expect(attendance.status).to eq 'cancelled'
              expect(attendance.last_status_change_date.to_i).to eq past_status_date_change.to_i
            end
          end
        end

        context 'and the group having no floor' do
          let(:group) { FactoryBot.create(:registration_group, minimum_size: 1) }

          context 'from pending' do
            let(:attendance) { FactoryBot.create(:attendance, registration_group: group, last_status_change_date: past_status_date_change) }
            context 'without invoice' do
              it 'move to confirm upon payment' do
                EmailNotifications.expects(:registration_confirmed).once
                attendance.pay
                expect(attendance.status).to eq 'confirmed'
                expect(attendance.last_status_change_date.to_i).to eq Time.zone.now.to_i
              end
            end

            context 'with an invoice' do
              it 'move attendance to confirm and invoice to paid upon payment' do
                EmailNotifications.expects(:registration_confirmed).once
                Invoice.from_attendance(attendance, 'gateway')
                attendance.pay
                expect(attendance.status).to eq 'confirmed'
                expect(Invoice.last.status).to eq 'paid'
                expect(attendance.last_status_change_date.to_i).to eq Time.zone.now.to_i
              end
            end
          end
        end
      end
    end

    describe '#cancel' do
      context 'when is waiting' do
        let(:attendance) { FactoryBot.create :attendance, status: :waiting, last_status_change_date: 2.days.from_now }
        let!(:invoice) { FactoryBot.create :invoice, user: attendance.user, invoiceable: attendance }
        it 'cancels the attendance and the invoice' do
          attendance.cancel
          expect(attendance.status).to eq 'cancelled'
          expect(attendance.invoices.last.status).to eq 'cancelled'
          expect(attendance.last_status_change_date.to_i).to eq Time.zone.now.to_i
        end
      end

      context 'when is pending' do
        let(:attendance) { FactoryBot.create :attendance, status: :pending, last_status_change_date: past_status_date_change }
        let!(:invoice) { FactoryBot.create :invoice, user: attendance.user, invoiceable: attendance }
        it 'cancels the attendance and the invoice' do
          attendance.cancel
          expect(attendance.status).to eq 'cancelled'
          expect(attendance.invoices.last.status).to eq 'cancelled'
          expect(attendance.last_status_change_date.to_i).to eq Time.zone.now.to_i
        end
      end

      context 'when is accepted' do
        let(:attendance) { FactoryBot.create :attendance, status: :accepted, last_status_change_date: past_status_date_change }
        let!(:invoice) { FactoryBot.create :invoice, user: attendance.user, invoiceable: attendance }

        it 'cancels the attendance' do
          attendance.cancel
          expect(attendance.status).to eq 'cancelled'
          expect(attendance.invoices.last.status).to eq 'cancelled'
          expect(attendance.last_status_change_date.to_i).to eq Time.zone.now.to_i
        end
      end

      context 'when is confirmed' do
        let(:attendance) { FactoryBot.create :attendance, status: :confirmed, last_status_change_date: past_status_date_change }
        let!(:invoice) { FactoryBot.create :invoice, user: attendance.user, invoiceable: attendance }
        it 'cancels the attendance' do
          attendance.cancel
          expect(attendance.status).to eq 'cancelled'
          expect(attendance.invoices.last.status).to eq 'cancelled'
          expect(attendance.last_status_change_date.to_i).to eq Time.zone.now.to_i
        end
      end

      context 'when is paid' do
        let(:attendance) { FactoryBot.create :attendance, status: :paid, last_status_change_date: past_status_date_change }
        let!(:invoice) { FactoryBot.create :invoice, user: attendance.user, invoiceable: attendance }
        it 'cancels the attendance' do
          attendance.cancel
          expect(attendance.status).to eq 'cancelled'
          expect(attendance.invoices.last.status).to eq 'cancelled'
          expect(attendance.last_status_change_date.to_i).to eq Time.zone.now.to_i
        end
      end
    end

    describe '#accept' do
      context 'when is waiting' do
        it 'keeps the attendance waiting' do
          EmailNotifications.expects(:registration_group_accepted).never
          attendance = FactoryBot.create :attendance, status: :waiting, last_status_change_date: past_status_date_change
          attendance.accept
          expect(attendance.status).to eq 'waiting'
          expect(attendance.last_status_change_date.to_i).to eq past_status_date_change.to_i
        end
      end

      context 'when is pending' do
        it 'accept the attendance' do
          EmailNotifications.expects(:registration_group_accepted).once
          attendance = FactoryBot.create :attendance, last_status_change_date: past_status_date_change
          attendance.accept
          expect(attendance.status).to eq 'accepted'
          expect(attendance.last_status_change_date.to_i).to eq Time.zone.now.to_i
        end
      end

      context 'when is cancelled' do
        it 'keep it cancelled' do
          EmailNotifications.expects(:registration_group_accepted).never
          attendance = FactoryBot.create :attendance, status: :cancelled, last_status_change_date: past_status_date_change
          attendance.accept
          expect(attendance.status).to eq 'cancelled'
          expect(attendance.last_status_change_date.to_i).to eq past_status_date_change.to_i
        end
      end

      context 'when is paid' do
        it 'keep it paid' do
          EmailNotifications.expects(:registration_group_accepted).never
          attendance = FactoryBot.create :attendance, status: :paid, last_status_change_date: past_status_date_change
          attendance.accept
          expect(attendance.status).to eq 'paid'
          expect(attendance.last_status_change_date.to_i).to eq past_status_date_change.to_i
        end
      end

      context 'when is already accepted' do
        it 'keep it accepted' do
          EmailNotifications.expects(:registration_group_accepted).never
          attendance = FactoryBot.create :attendance, status: :accepted, last_status_change_date: past_status_date_change
          attendance.accept
          expect(attendance.status).to eq 'accepted'
          expect(attendance.last_status_change_date.to_i).to eq past_status_date_change.to_i
        end
      end

      context 'when belongs to a free group' do
        it 'confirms' do
          EmailNotifications.expects(:registration_group_accepted).never
          group = FactoryBot.create :registration_group, discount: 100
          attendance = FactoryBot.create :attendance, status: :pending, registration_group: group, last_status_change_date: past_status_date_change
          attendance.accept
          expect(attendance.status).to eq 'confirmed'
          expect(attendance.last_status_change_date.to_i).to eq Time.zone.now.to_i
        end
      end
    end

    describe '#confirm' do
      context 'when is waiting' do
        it 'keeps waiting' do
          EmailNotifications.expects(:registration_confirmed).never
          attendance = FactoryBot.create :attendance, status: :waiting, last_status_change_date: past_status_date_change
          attendance.confirm
          expect(attendance.status).to eq 'waiting'
          expect(attendance.last_status_change_date.to_i).to eq past_status_date_change.to_i
        end
      end

      context 'when is pending' do
        it 'confirms the attendance' do
          EmailNotifications.expects(:registration_confirmed).once
          attendance = FactoryBot.create :attendance, last_status_change_date: past_status_date_change
          Invoice.from_attendance(attendance, 'gateway')
          attendance.confirm
          expect(attendance.status).to eq 'confirmed'
          expect(Invoice.last.status).to eq 'paid'
          expect(attendance.last_status_change_date.to_i).to eq Time.zone.now.to_i
        end
      end

      context 'when is accepted' do
        it 'confirms the attendance' do
          EmailNotifications.expects(:registration_confirmed).once
          attendance = FactoryBot.create :attendance, status: :accepted, last_status_change_date: past_status_date_change
          attendance.confirm
          expect(attendance.status).to eq 'confirmed'
          expect(attendance.last_status_change_date.to_i).to eq Time.zone.now.to_i
        end
      end

      context 'when is cancelled' do
        it 'keep it cancelled' do
          EmailNotifications.expects(:registration_confirmed).never
          attendance = FactoryBot.create :attendance, status: :cancelled, last_status_change_date: past_status_date_change
          attendance.confirm
          expect(attendance.status).to eq 'cancelled'
          expect(attendance.last_status_change_date.to_i).to eq past_status_date_change.to_i
        end
      end

      context 'when is paid' do
        it 'keep it paid' do
          EmailNotifications.expects(:registration_confirmed).once
          attendance = FactoryBot.create :attendance, status: :paid, last_status_change_date: past_status_date_change
          attendance.confirm
          expect(attendance.status).to eq 'confirmed'
          expect(attendance.last_status_change_date.to_i).to eq Time.zone.now.to_i
        end
      end
    end

    describe '#mark_no_show' do
      context 'when is waiting' do
        it 'keep it waiting' do
          attendance = FactoryBot.create :attendance, status: :waiting, last_status_change_date: past_status_date_change
          attendance.expects(:cancel_invoice!).never
          attendance.mark_no_show
          expect(attendance.status).to eq 'waiting'
          expect(attendance.last_status_change_date.to_i).to eq past_status_date_change.to_i
        end
      end

      context 'when is pending' do
        it 'mark as no show' do
          attendance = FactoryBot.create :attendance, last_status_change_date: past_status_date_change
          attendance.expects(:cancel_invoice!).once
          attendance.mark_no_show
          expect(attendance.status).to eq 'no_show'
          expect(attendance.last_status_change_date.to_i).to eq Time.zone.now.to_i
        end
      end

      context 'when is accepted' do
        it 'mark as no show' do
          attendance = FactoryBot.create :attendance, status: :accepted, last_status_change_date: past_status_date_change
          attendance.expects(:cancel_invoice!).once
          attendance.mark_no_show
          expect(attendance.status).to eq 'no_show'
          expect(attendance.last_status_change_date.to_i).to eq Time.zone.now.to_i
        end
      end

      context 'when is cancelled' do
        it 'keep it cancelled' do
          attendance = FactoryBot.create :attendance, status: :cancelled, last_status_change_date: past_status_date_change
          attendance.expects(:cancel_invoice!).never
          attendance.mark_no_show
          expect(attendance.status).to eq 'cancelled'
          expect(attendance.last_status_change_date.to_i).to eq past_status_date_change.to_i
        end
      end

      context 'when is paid' do
        it 'keep it paid' do
          attendance = FactoryBot.create :attendance, status: :paid, last_status_change_date: past_status_date_change
          attendance.expects(:cancel_invoice!).never
          attendance.mark_no_show
          expect(attendance.status).to eq 'paid'
          expect(attendance.last_status_change_date.to_i).to eq past_status_date_change.to_i
        end
      end

      context 'when is confirmed' do
        it 'keep it confirmed' do
          attendance = FactoryBot.create :attendance, status: :confirmed, last_status_change_date: past_status_date_change
          attendance.expects(:cancel_invoice!).never
          attendance.mark_no_show
          expect(attendance.status).to eq 'confirmed'
          expect(attendance.last_status_change_date.to_i).to eq past_status_date_change.to_i
        end
      end
    end

    describe '#dequeue' do
      context 'when is waiting' do
        it 'removes the attendance from the queue' do
          Timecop.freeze
          now = Time.zone.now
          creation_time = now.to_i - 10 * 24 * 60 * 60
          attendance = FactoryBot.create :attendance, status: :waiting, created_at: Time.zone.at(creation_time), last_status_change_date: past_status_date_change
          email = stub(deliver_now: true)
          EmailNotifications.expects(:registration_dequeued).once.returns(email)
          attendance.dequeue
          expect(attendance.status).to eq 'pending'
          expect(attendance.queue_time).to eq 240
          expect(attendance.last_status_change_date.to_i).to eq Time.zone.now.to_i
          Timecop.return
        end
      end

      context 'when is pending' do
        it 'keep it pending' do
          attendance = FactoryBot.create :attendance, last_status_change_date: past_status_date_change
          EmailNotifications.expects(:registration_dequeued).never
          attendance.dequeue
          expect(attendance.status).to eq 'pending'
          expect(attendance.last_status_change_date.to_i).to eq past_status_date_change.to_i
        end
      end

      context 'when is accepted' do
        it 'keep it accepted' do
          attendance = FactoryBot.create :attendance, status: :accepted, last_status_change_date: past_status_date_change
          EmailNotifications.expects(:registration_dequeued).never
          attendance.dequeue
          expect(attendance.status).to eq 'accepted'
          expect(attendance.last_status_change_date.to_i).to eq past_status_date_change.to_i
        end
      end

      context 'when is cancelled' do
        it 'keep it cancelled' do
          attendance = FactoryBot.create :attendance, status: :cancelled, last_status_change_date: past_status_date_change
          EmailNotifications.expects(:registration_dequeued).never
          attendance.dequeue
          expect(attendance.status).to eq 'cancelled'
          expect(attendance.last_status_change_date.to_i).to eq past_status_date_change.to_i
        end
      end

      context 'when is paid' do
        it 'keep it paid' do
          attendance = FactoryBot.create :attendance, status: :paid, last_status_change_date: past_status_date_change
          EmailNotifications.expects(:registration_dequeued).never
          attendance.dequeue
          expect(attendance.status).to eq 'paid'
          expect(attendance.last_status_change_date.to_i).to eq past_status_date_change.to_i
        end
      end

      context 'when is confirmed' do
        it 'keep it confirmed' do
          attendance = FactoryBot.create :attendance, status: :confirmed, last_status_change_date: past_status_date_change
          EmailNotifications.expects(:registration_dequeued).never
          attendance.dequeue
          expect(attendance.status).to eq 'confirmed'
          expect(attendance.last_status_change_date.to_i).to eq past_status_date_change.to_i
        end
      end
    end
  end

  describe '#cancellable?' do
    let(:attendance) { FactoryBot.build(:attendance) }

    context 'when is waiting' do
      let(:waiting) { FactoryBot.build(:attendance, status: :waiting) }
      it { expect(waiting).to be_cancellable }
    end

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
    let(:attendance) { FactoryBot.build(:attendance) }
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
    let(:attendance) { FactoryBot.build(:attendance) }
    context 'when is pending' do
      it { expect(attendance).to be_confirmable }
    end

    context 'when is accepted' do
      before { attendance.accept }
      it { expect(attendance).to be_confirmable }
    end

    context 'when is paid' do
      context 'and grouped' do
        let(:group) { FactoryBot.create(:registration_group) }
        let(:grouped_attendance) { FactoryBot.create(:attendance, registration_group: group) }
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
    let(:attendance) { FactoryBot.build(:attendance) }
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
    let(:attendance) { FactoryBot.build(:attendance) }
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
    let(:event) { FactoryBot.create(:event) }
    context 'when is not member of a group' do
      let!(:attendance) { FactoryBot.create(:attendance, event: event) }
      it { expect(attendance.discount).to eq 1 }
    end

    context 'when is member of a 30% group' do
      let(:group) { FactoryBot.create(:registration_group, event: event, discount: 30) }
      let!(:attendance) { FactoryBot.create(:attendance, event: event, registration_group: group) }
      it { expect(attendance.discount).to eq 0.7 }
    end

    context 'when is member of a 100% group' do
      let(:group) { FactoryBot.create(:registration_group, event: event, discount: 100) }
      let!(:attendance) { FactoryBot.create(:attendance, event: event, registration_group: group) }
      it { expect(attendance.discount).to eq 0 }
    end
  end

  describe '#group_name' do
    let(:event) { FactoryBot.create(:event) }
    context 'with a registration group' do
      let!(:group) { FactoryBot.create :registration_group, event: event }
      let!(:attendance) { FactoryBot.create(:attendance, event: event, registration_group: group) }
      it { expect(attendance.group_name).to eq group.name }
    end

    context 'with no registration group' do
      let!(:attendance) { FactoryBot.create(:attendance, event: event) }
      it { expect(attendance.group_name).to eq nil }
    end
  end

  describe '#event_name' do
    context 'with an event' do
      let(:event) { FactoryBot.create(:event) }
      let!(:attendance) { FactoryBot.create(:attendance, event: event) }
      it { expect(attendance.event_name).to eq event.name }
    end
  end

  describe '#grouped?' do
    let(:event) { FactoryBot.create(:event) }

    context 'when belongs to a group' do
      let(:group) { FactoryBot.create :registration_group, event: event }
      let!(:attendance) { FactoryBot.create(:attendance, event: event, registration_group: group) }
      it { expect(attendance.grouped?).to be_truthy }
    end

    context 'when not belonging to a group' do
      let!(:attendance) { FactoryBot.create(:attendance, event: event) }
      it { expect(attendance.grouped?).to be_falsey }
    end
  end

  describe '#advise!' do
    context 'when the due date is in a workday' do
      let!(:now) { Time.zone.local(2017, 5, 4, 0, 0, 0) }
      before do
        Time.zone.stubs(:today).returns(Date.new(2017, 5, 4))
        Time.zone.stubs(:now).returns(now)
      end

      let(:event) { FactoryBot.create :event, days_to_charge: 1 }
      let!(:attendance) { FactoryBot.create(:attendance, event: event) }

      before { attendance.advise! }
      it { expect(Attendance.last.advised).to be_truthy }
      it { expect(Attendance.last.advised_at).to eq now }
      it { expect(Attendance.last.due_date).to eq Time.zone.local(2017, 5, 5, 0, 0, 0) }
    end

    context 'when the due date is in a weekend' do
      let!(:now) { Time.zone.local(2017, 5, 6, 0, 0, 0) }
      before do
        Time.zone.stubs(:today).returns(Date.new(2017, 5, 6))
        Time.zone.stubs(:now).returns(now)
      end

      let(:event) { FactoryBot.create :event, days_to_charge: 1 }
      let!(:attendance) { FactoryBot.create(:attendance, event: event) }

      before { attendance.advise! }
      it { expect(Attendance.last.due_date).to eq Time.zone.local(2017, 5, 8, 0, 0, 0) }
    end

    context 'when the event start date is before the attendance due date' do
      let!(:now) { Time.zone.local(2017, 5, 6, 0, 0, 0) }
      before do
        Time.zone.stubs(:today).returns(Date.new(2017, 5, 6))
        Time.zone.stubs(:now).returns(now)
      end

      let(:event) { FactoryBot.create :event, start_date: Date.new(2017, 5, 8), days_to_charge: 5 }
      let!(:attendance) { FactoryBot.create(:attendance, event: event) }

      let(:attendance) { FactoryBot.create(:attendance, event: event) }
      before { attendance.advise! }
      it { expect(Attendance.last.due_date).to eq Time.zone.local(2017, 5, 8, 0, 0, 0) }
    end
  end

  context 'delegations' do
    describe '#token' do
      let(:group) { FactoryBot.create :registration_group }
      let(:attendance) { FactoryBot.create :attendance, registration_group: group }

      it { expect(attendance.token).to eq group.token }
      it { expect(attendance.group_name).to eq group.name }
      it { expect(attendance.event_name).to eq attendance.event.name }
    end
  end

  describe '#to_s' do
    let(:attendance) { FactoryBot.create :attendance, first_name: 'foo', last_name: 'bar' }
    it { expect(attendance.to_s).to eq 'bar, foo' }
  end

  describe '#to_pay_the_difference?' do
    context 'not paid attendance' do
      let(:attendance) { FactoryBot.create :attendance, first_name: 'foo', last_name: 'bar' }
      it { expect(attendance.to_pay_the_difference?).to be_falsey }
    end
    context 'paid attendance not grouped' do
      let(:attendance) { FactoryBot.create :attendance, first_name: 'foo', last_name: 'bar', status: :paid }
      it { expect(attendance.to_pay_the_difference?).to be_falsey }
    end
    context 'confirmed attendance not grouped' do
      let(:attendance) { FactoryBot.create :attendance, first_name: 'foo', last_name: 'bar', status: :confirmed }
      it { expect(attendance.to_pay_the_difference?).to be_falsey }
    end
    context 'paid and grouped, but the group is complete' do
      let(:group) { FactoryBot.create(:registration_group, minimum_size: 1) }
      let(:attendance) { FactoryBot.create :attendance, first_name: 'foo', last_name: 'bar', status: :paid, registration_group: group }
      it { expect(attendance.to_pay_the_difference?).to be_falsey }
    end
    context 'paid and grouped, but the group is incomplete' do
      let(:group) { FactoryBot.create(:registration_group, minimum_size: 2) }
      let(:attendance) { FactoryBot.create :attendance, first_name: 'foo', last_name: 'bar', status: :paid, registration_group: group }
      it { expect(attendance.to_pay_the_difference?).to be_truthy }
    end
    context 'confirmed and grouped, but the group is incomplete' do
      let(:group) { FactoryBot.create(:registration_group, minimum_size: 2) }
      let(:attendance) { FactoryBot.create :attendance, first_name: 'foo', last_name: 'bar', status: :confirmed, registration_group: group }
      it { expect(attendance.to_pay_the_difference?).to be_truthy }
    end
  end

  describe '#payment_type' do
    context 'having invoices' do
      let!(:attendance) { FactoryBot.create(:attendance) }
      let!(:invoice) { Invoice.from_attendance(attendance) }
      it { expect(attendance.payment_type).to eq 'gateway' }
    end
    context 'and without invoices' do
      let!(:attendance) { FactoryBot.create(:attendance) }
      it { expect(attendance.payment_type).to eq nil }
    end
  end

  describe '#price_band?' do
    context 'having period' do
      let(:period) { FactoryBot.create(:registration_period) }
      let!(:attendance) { FactoryBot.create(:attendance, registration_period: period) }
      it { expect(attendance.price_band?).to be_truthy }
    end
    context 'having quota' do
      let(:quota) { FactoryBot.create(:registration_quota) }
      let!(:attendance) { FactoryBot.create(:attendance, registration_quota: quota) }
      it { expect(attendance.price_band?).to be_truthy }
    end
    context 'having no bands' do
      let!(:attendance) { FactoryBot.create(:attendance) }
      it { expect(attendance.price_band?).to be_falsey }
    end
  end

  describe '#band_value' do
    context 'having period' do
      let(:period) { FactoryBot.create(:registration_period) }
      let!(:attendance) { FactoryBot.create(:attendance, registration_period: period) }
      it { expect(attendance.band_value).to eq period.price }
    end
    context 'having quota' do
      let(:quota) { FactoryBot.create(:registration_quota) }
      let!(:attendance) { FactoryBot.create(:attendance, registration_quota: quota) }
      it { expect(attendance.band_value).to eq quota.price }
    end
    context 'having no bands' do
      let!(:attendance) { FactoryBot.create(:attendance) }
      it { expect(attendance.band_value).to be_nil }
    end
  end
end
