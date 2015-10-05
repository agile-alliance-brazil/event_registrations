# == Schema Information
#
# Table name: attendances
#
#  id                     :integer          not null, primary key
#  event_id               :integer
#  user_id                :integer
#  registration_type_id   :integer
#  registration_group_id  :integer
#  registration_date      :datetime
#  status                 :string
#  email_sent             :boolean          default(FALSE)
#  created_at             :datetime
#  updated_at             :datetime
#  first_name             :string
#  last_name              :string
#  email                  :string
#  organization           :string
#  phone                  :string
#  country                :string
#  state                  :string
#  city                   :string
#  badge_name             :string
#  cpf                    :string
#  gender                 :string
#  twitter_user           :string
#  address                :string
#  neighbourhood          :string
#  zipcode                :string
#  notes                  :string
#  event_price            :decimal(, )
#  registration_quota_id  :integer
#  registration_value     :decimal(, )
#  registration_period_id :integer
#  advised                :boolean          default(FALSE)
#  advised_at             :datetime
#

describe Attendance, type: :model do
  context 'associations' do
    it { should belong_to :event }
    it { should belong_to :user }
    it { should belong_to :registration_type }
    it { should belong_to :registration_group }
    it { should belong_to :registration_quota }
    it { should have_many :invoice_attendances }
    it { should have_many(:invoices).through(:invoice_attendances) }
  end

  context 'validations' do
    it { should validate_presence_of :first_name }
    it { should validate_presence_of :last_name }
    it { should validate_presence_of :email }
    it { should validate_presence_of :phone }
    it { should validate_presence_of :country }
    it { should validate_presence_of :city }

    it { should allow_value('1234-2345').for(:phone) }
    it { should allow_value('+55 11 5555 2234').for(:phone) }
    it { should allow_value('+1 (304) 543.3333').for(:phone) }
    it { should allow_value('07753423456').for(:phone) }
    it { should_not allow_value('a').for(:phone) }
    it { should_not allow_value('1234-bfd').for(:phone) }
    it { should_not allow_value(')(*&^%$@!').for(:phone) }
    it { should_not allow_value('[=+]').for(:phone) }

    context 'brazilians' do
      subject { FactoryGirl.build(:attendance, :country => 'BR') }
      it { should validate_presence_of :state }
      it { should validate_presence_of :cpf }
    end

    context 'foreigners' do
      subject { FactoryGirl.build(:attendance, :country => 'US') }
      it { should_not validate_presence_of :state }
      it { should_not validate_presence_of :cpf }
    end

    it { should validate_length_of(:email).is_at_least(6).is_at_most(100) }
    it { should validate_length_of(:first_name).is_at_most(100) }
    it { should validate_length_of(:last_name).is_at_most(100) }
    it { should validate_length_of(:city).is_at_most(100) }
    it { should validate_length_of(:organization).is_at_most(100) }

    it { should allow_value('user@domain.com.br').for(:email) }
    it { should allow_value('test_user.name@a.co.uk').for(:email) }
    it { should_not allow_value('a').for(:email) }
    it { should_not allow_value('a@').for(:email) }
    it { should_not allow_value('a@a').for(:email) }
    it { should_not allow_value('@12.com').for(:email) }
  end

  context 'callbacks' do
    let!(:event) { FactoryGirl.create :event }
    describe '#update_group_invoice' do
      context 'having a registration group' do
        let(:group) { RegistrationGroup.create! event: event }
        let!(:invoice) { FactoryGirl.create :invoice, registration_group: group, amount: 50.00 }
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

      it 'should have scope for_registration_type' do
        rt = FactoryGirl.create(:registration_type, :event => Attendance.first.event)
        Attendance.first.tap { |a| a.registration_type = rt }.save

        expect(Attendance.for_registration_type(rt)).to eq([Attendance.first])
      end

      it 'should have scope without_registration_type' do
        rt = FactoryGirl.create(:registration_type, :event => Attendance.first.event)
        Attendance.first.tap { |a| a.registration_type = rt }.save

        expect(Attendance.without_registration_type(rt)).not_to include(Attendance.first)
      end

      it { expect(Attendance.pending).to include(Attendance.first) }

      it 'should have scope accepted' do
        Attendance.first.tap(&:accept).save
        expect(Attendance.accepted).to include Attendance.first
      end

      it 'should have scope paid' do
        Attendance.first.tap(&:pay).save
        expect(Attendance.paid).to eq([Attendance.first])
      end

      it 'should have scope active that excludes cancelled attendances' do
        Attendance.first.tap(&:cancel).save
        expect(Attendance.active).not_to include(Attendance.first)
      end

      it 'should have scope older_than that selects old attendances' do
        Attendance.first.tap { |a| a.registration_date = 10.days.ago }.save
        expect(Attendance.older_than(5.days.ago)).to eq([Attendance.first])
      end
    end

    context 'with specific seed' do
      describe '.search_for_list' do
        context 'and no attendances' do
          it { expect(Attendance.search_for_list('bla', [])).to eq [] }
        end

        context 'and having attendances' do
          let!(:attendance) { FactoryGirl.create(:attendance, first_name: 'xpto', last_name: 'bla', organization: 'foo', email: 'sbrubles@xpto.com', email_confirmation: 'sbrubles@xpto.com') }

          let(:all_statuses) { %w(pending accepted paid confirmed cancelled) }

          context 'with one attendance' do
            context 'and matching fields' do
              context 'entire field' do
                it { expect(Attendance.search_for_list('xPTo', all_statuses)).to match_array [attendance] }
                it { expect(Attendance.search_for_list('bLa', all_statuses)).to match_array [attendance] }
                it { expect(Attendance.search_for_list('FoO', all_statuses)).to match_array [attendance] }
                it { expect(Attendance.search_for_list('sbRUblEs', all_statuses)).to match_array [attendance] }
              end

              context 'field part' do
                it { expect(Attendance.search_for_list('PT', all_statuses)).to match_array [attendance] }
                it { expect(Attendance.search_for_list('bL', all_statuses)).to match_array [attendance] }
                it { expect(Attendance.search_for_list('oO', all_statuses)).to match_array [attendance] }
                it { expect(Attendance.search_for_list('RUblEs', all_statuses)).to match_array [attendance] }
              end
            end
          end

          context 'with three attendances, one not matching' do
            let!(:other_attendance) { FactoryGirl.create(:attendance, first_name: 'bla', last_name: 'xpto', organization: 'sbrubles', email: 'foo@xpto.com', email_confirmation: 'foo@xpto.com') }
            let!(:out_attendance) { FactoryGirl.create(:attendance, first_name: 'Edsger', last_name: 'Dijkstra', organization: 'Turing', email: 'algorithm@node.path', email_confirmation: 'algorithm@node.path') }

            context 'entire field' do
              it { expect(Attendance.search_for_list('xPTo', all_statuses)).to match_array [attendance, other_attendance] }
              it { expect(Attendance.search_for_list('bLa', all_statuses)).to match_array [attendance, other_attendance] }
              it { expect(Attendance.search_for_list('FoO', all_statuses)).to match_array [attendance, other_attendance] }
              it { expect(Attendance.search_for_list('sbRUblEs', all_statuses)).to match_array [attendance, other_attendance] }
              it { expect(Attendance.search_for_list(attendance.id, all_statuses)).to match_array [attendance] }
            end

            context 'field part' do
              it { expect(Attendance.search_for_list('PT', all_statuses)).to match_array [attendance, other_attendance] }
              it { expect(Attendance.search_for_list('bL', all_statuses)).to match_array [attendance, other_attendance] }
              it { expect(Attendance.search_for_list('oO', all_statuses)).to match_array [attendance, other_attendance] }
              it { expect(Attendance.search_for_list('RUblEs', all_statuses)).to match_array [attendance, other_attendance] }
            end
          end

          context 'with three attendances, all matching' do
            let!(:event) { FactoryGirl.create :event }
            it 'will order by created at descending' do
              now = Time.zone.local(2015, 4, 30, 0, 0, 0)
              Timecop.freeze(now)
              attendance = FactoryGirl.create(:attendance, event: event, first_name: 'April event')
              now = Time.zone.local(2014, 4, 30, 0, 0, 0)
              Timecop.freeze(now)
              other_attendance = FactoryGirl.create(:attendance, event: event, first_name: '2014 event')
              Timecop.return
              another_attendance = FactoryGirl.create(:attendance, event: event, first_name: 'Today event')

              expect(Attendance.search_for_list('event', all_statuses)).to eq [another_attendance, attendance, other_attendance]
            end
          end
        end
      end

      describe '.for_cancelation_warning' do
        context 'with valid status and gateway as payment type' do
          it 'returns the attendance' do
            pending_gateway = FactoryGirl.create(:attendance, status: :pending, registration_date: 7.days.ago)
            accepted_gateway = FactoryGirl.create(:attendance, status: :accepted, registration_date: 7.days.ago)
            Invoice.from_attendance(pending_gateway, Invoice::GATEWAY)
            Invoice.from_attendance(accepted_gateway, Invoice::GATEWAY)
            expect(Attendance.for_cancelation_warning).to match_array [pending_gateway, accepted_gateway]
          end
        end

        context 'with two pending and gateway as payment type' do
          it 'returns the both attendances' do
            pending_gateway = FactoryGirl.create(:attendance, status: :pending, registration_date: 7.days.ago)
            Invoice.from_attendance(pending_gateway, Invoice::GATEWAY)

            other_pending_gateway = FactoryGirl.create(:attendance, status: :pending, registration_date: 7.days.ago)
            Invoice.from_attendance(other_pending_gateway, Invoice::GATEWAY)

            expect(Attendance.for_cancelation_warning).to eq [pending_gateway, other_pending_gateway]
          end
        end

        context 'with one pending and gateway as payment type and other bank deposit' do
          it 'returns the attendance pending gateway' do
            pending_gateway = FactoryGirl.create(:attendance, status: :pending, registration_date: 7.days.ago)
            Invoice.from_attendance(pending_gateway, Invoice::GATEWAY)

            pending_deposit = FactoryGirl.create(:attendance, status: :pending, registration_date: 7.days.ago)
            Invoice.from_attendance(pending_deposit, Invoice::DEPOSIT)

            expect(Attendance.for_cancelation_warning).to eq [pending_gateway]
          end
        end

        context 'with one pending and gateway as payment type and other statement of agreement' do
          it 'returns the attendance pending gateway' do
            pending_gateway = FactoryGirl.create(:attendance, status: :pending, registration_date: 7.days.ago)
            Invoice.from_attendance(pending_gateway, Invoice::GATEWAY)

            pending_statement = FactoryGirl.create(:attendance, status: :pending, registration_date: 7.days.ago)
            Invoice.from_attendance(pending_statement, Invoice::STATEMENT)

            expect(Attendance.for_cancelation_warning).to eq [pending_gateway]
          end
        end
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

      describe '.for_cancelation' do
        let!(:to_cancel) { FactoryGirl.create(:attendance, advised_at: 8.days.ago, advised: true) }
        let!(:out) { FactoryGirl.create(:attendance, advised_at: 5.days.ago, advised: true) }
        let!(:other_out) { FactoryGirl.create(:attendance, advised_at: nil, advised: false, created_at: 15.days.ago) }
        it { expect(Attendance.for_cancelation).to eq [to_cancel] }
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
                expect { attendance.pay }.not_to raise_error
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

      context 'when is individual' do
        context 'from pending' do
          let(:attendance) { FactoryGirl.create(:attendance) }

          context 'without invoice' do
            it 'move to paid upon payment' do
              attendance.pay
              expect { attendance.pay }.not_to raise_error
              expect(attendance.status).to eq 'confirmed'
            end
          end

          context 'with invoice' do
            it 'move attendance to CONFIRMED upon payment and keep invoice as paid' do
              Invoice.from_attendance(attendance, Invoice::GATEWAY)
              EmailNotifications.expects(:registration_confirmed).once
              attendance.pay
              expect(attendance.status).to eq 'confirmed'
              expect(Invoice.last.status).to eq 'paid'
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
    end

    describe '#confirm' do
      context 'when is pending' do
        it 'confirm the attendance' do
          EmailNotifications.expects(:registration_confirmed).once
          attendance = FactoryGirl.create :attendance
          attendance.confirm
          expect(attendance.status).to eq 'confirmed'
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
      let(:individual) { RegistrationType.create!(title: 'registration_type.individual', event: event) }
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_type: individual) }
      it { expect(attendance.discount).to eq 1 }
    end

    context 'when is member of a 30% group' do
      let(:individual) { RegistrationType.create!(title: 'registration_type.individual', event: event) }
      let(:group) { FactoryGirl.create(:registration_group, event: event, discount: 30) }
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_type: individual, registration_group: group) }
      it { expect(attendance.discount).to eq 0.7 }
    end

    context 'when is member of a 100% group' do
      let(:individual) { RegistrationType.create!(title: 'registration_type.individual', event: event) }
      let(:group) { FactoryGirl.create(:registration_group, event: event, discount: 100) }
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_type: individual, registration_group: group) }
      it { expect(attendance.discount).to eq 0 }
    end
  end

  describe '#group_name' do
    let(:event) { FactoryGirl.create(:event) }
    context 'with a registration group' do
      let!(:group) { FactoryGirl.create :registration_group, event: event }
      let(:individual) { RegistrationType.create!(title: 'registration_type.individual', event: event) }
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_type: individual, registration_group: group) }
      it { expect(attendance.group_name).to eq group.name }
    end

    context 'with no registration group' do
      let(:individual) { RegistrationType.create!(title: 'registration_type.individual', event: event) }
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_type: individual) }
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
    let(:individual) { RegistrationType.create!(title: 'registration_type.individual', event: event) }

    context 'when belongs to a group' do
      let(:group) { RegistrationGroup.create! event: event }
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group, registration_type: individual) }

      it { expect(attendance.grouped?).to be_truthy }
    end

    context 'when not belonging to a group' do
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_type: individual) }

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
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, status: :pending, first_name: 'bLa') }
      let(:expected) do
        "first_name,last_name,organization,email\n#{attendance.first_name},#{attendance.last_name},#{attendance.organization},#{attendance.email}\n"
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

  pending 'delegates'
end
