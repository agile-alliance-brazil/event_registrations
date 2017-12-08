RSpec.describe AttendancesController, type: :controller do
  let(:user) { FactoryBot.create(:user) }
  let(:event) { FactoryBot.create(:event, full_price: 930.00) }

  before :each do
    user.add_role :organizer
    user.save
    disable_authorization
    sign_in user
  end

  describe 'GET #index' do
    let(:user) { FactoryBot.create(:user) }
    before do
      sign_in user
      disable_authorization
    end

    context 'passing no search parameter' do
      context 'and no attendances' do
        let!(:event) { FactoryBot.create(:event) }
        before { get :index, params: { event_id: event, pending: 'pending', accepted: 'accepted', paid: 'paid', confirmed: 'confirmed', cancelled: 'cancelled' } }
        it { expect(assigns(:attendances_list)).to eq [] }
      end

      context 'and having attendances' do
        let!(:attendance) { FactoryBot.create(:attendance) }
        context 'and one attendance, but no association with event' do
          let!(:event) { FactoryBot.create(:event) }
          before { get :index, params: { event_id: event, pending: 'pending', accepted: 'accepted', paid: 'paid', confirmed: 'confirmed', cancelled: 'cancelled' } }
          it { expect(assigns(:attendances_list)).to eq [] }
        end
        context 'having attendances and reservations' do
          let!(:event) { FactoryBot.create(:event) }
          let!(:pending) { FactoryBot.create(:attendance, event: event, status: :pending) }
          let!(:waiting) { FactoryBot.create(:attendance, event: event, status: :waiting) }
          let!(:accepted) { FactoryBot.create(:attendance, event: event, status: :accepted) }
          let!(:paid) { FactoryBot.create(:attendance, event: event, status: :paid) }
          let!(:confirmed) { FactoryBot.create(:attendance, event: event, status: :confirmed) }
          let!(:cancelled) { FactoryBot.create(:attendance, event: event, status: :cancelled) }
          let!(:group) { FactoryBot.create :registration_group, event: event, paid_in_advance: true, capacity: 3, amount: 100 }

          before { get :index, params: { event_id: event.id, pending: 'pending', accepted: 'accepted', paid: 'paid', confirmed: 'confirmed', cancelled: 'cancelled' } }
          it 'assigns the instance variables and renders the template' do
            expect(response).to render_template :index
            expect(assigns(:attendances_list)).to match_array [pending, accepted, paid, confirmed]
            expect(assigns(:waiting_total)).to eq 1
            expect(assigns(:pending_total)).to eq 1
            expect(assigns(:accepted_total)).to eq 1
            expect(assigns(:paid_total)).to eq 2
            expect(assigns(:reserved_total)).to eq 3
            expect(assigns(:cancelled_total)).to eq 1
            expect(assigns(:total)).to eq 7
            expect(assigns(:burnup_registrations_data).ideal.count).to eq 32
            expect(assigns(:burnup_registrations_data).actual.count).to eq 1
          end
        end
      end
    end
  end

  describe 'GET #show' do
    context 'with a valid attendance' do
      let!(:event) { FactoryBot.create(:event) }
      let!(:attendance) { FactoryBot.create(:attendance, event: event, user: user) }
      context 'having invoice' do
        let!(:invoice) { Invoice.from_attendance(attendance, 'gateway') }
        before { get :show, params: { id: attendance.id } }
        it { expect(assigns[:attendance]).to eq attendance }
        it { expect(response).to be_success }
      end

      context 'having no invoice' do
        before { get :show, params: { id: attendance.id } }
        it { expect(assigns[:attendance]).to eq attendance }
        it { expect(response).to be_success }
      end
    end
  end

  describe 'DELETE #destroy' do
    subject(:attendance) { FactoryBot.create(:attendance) }

    it 'cancels attendance' do
      Attendance.any_instance.expects(:cancel)
      delete :destroy, params: { id: attendance.id }
    end

    it 'not delete attendance' do
      Attendance.any_instance.expects(:destroy).never
      delete :destroy, params: { id: attendance.id }
    end

    it 'redirects back to status' do
      delete :destroy, params: { id: attendance.id }
      expect(response).to redirect_to(attendance_path(attendance))
    end

    context 'with invoice' do
      it 'cancel the attendance and the invoice' do
        Invoice.from_attendance(attendance, 'gateway')
        delete :destroy, params: { id: attendance.id }
        expect(Attendance.last.status).to eq 'cancelled'
        expect(Invoice.last.status).to eq 'cancelled'
      end
    end
  end

  describe 'PUT #confirm' do
    context 'responding HTML' do
      let!(:attendance) { FactoryBot.create(:attendance) }
      it 'confirms attendance' do
        EmailNotifications.stubs(:registration_confirmed).returns(stub(deliver_now: true))
        Attendance.any_instance.expects(:confirm)
        put :confirm, params: { id: attendance.id }
      end

      it 'redirects back to status' do
        EmailNotifications.stubs(:registration_confirmed).returns(stub(deliver_now: true))
        put :confirm, params: { id: attendance.id }

        expect(response).to redirect_to(attendance_path(attendance))
      end

      it 'notifies airbrake if cannot send email' do
        exception = StandardError.new
        action = :registration_confirmed
        EmailNotifications.expects(action).raises(exception)

        Airbrake.expects(:notify).with(exception.message, action: action, attendance: attendance)

        put :confirm, params: { id: attendance.id }

        expect(response).to redirect_to(attendance_path(attendance))
      end

      it 'ignores airbrake errors if cannot send email' do
        exception = StandardError.new
        action = :registration_confirmed
        EmailNotifications.expects(action).raises(exception)
        Airbrake.expects(:notify)
                .with(exception.message, action: action, attendance: attendance)
                .raises(exception)

        put :confirm, params: { id: attendance.id }

        expect(response).to redirect_to(attendance_path(attendance))
      end
    end

    context 'responding JS' do
      let!(:attendance) { FactoryBot.create(:attendance) }

      it 'marks attendance as confirmed, save when this occurs and redirect to attendances index' do
        put :confirm, params: { id: attendance.id }, xhr: true
        expect(assigns(:attendance)).to eq attendance
        expect(Attendance.last.status).to eq 'confirmed'
      end
    end
  end

  describe 'PUT #pay_it' do
    let!(:event) { FactoryBot.create(:event) }

    context 'pending attendance' do
      context 'grouped attendance' do
        let(:group) { FactoryBot.create :registration_group }
        let(:attendance) { FactoryBot.create(:attendance, event: event, registration_group: group, status: 'pending') }
        let!(:invoice) { Invoice.from_attendance(attendance, 'gateway') }
        it 'marks attendance and related invoice as paid, save when this occurs and redirect to attendances index' do
          put :pay_it, params: { id: attendance.id }, xhr: true
          expect(assigns(:attendance)).to eq attendance
          expect(Attendance.last.status).to eq 'paid'
          expect(Invoice.last.status).to eq 'paid'
        end
      end

      context 'individual attendance' do
        let(:attendance) { FactoryBot.create(:attendance, event: event, status: 'pending') }
        let!(:invoice) { Invoice.from_attendance(attendance, 'gateway') }
        it 'marks attendance as confirmed and related invoice as paid and redirect to attendances index' do
          EmailNotifications.expects(:registration_confirmed).once
          put :pay_it, params: { id: attendance.id }, xhr: true
          expect(assigns(:attendance)).to eq attendance
          expect(Attendance.last.status).to eq 'confirmed'
          expect(Invoice.last.status).to eq 'paid'
        end
      end
    end

    context 'cancelled attendance' do
      let!(:attendance) { FactoryBot.create(:attendance, event: event, status: 'cancelled') }
      it 'doesnt mark as paid and redirect to attendances index with alert' do
        put :pay_it, params: { id: attendance.id }, xhr: true
        expect(assigns(:attendance)).to eq attendance
        expect(Attendance.last.status).to eq 'cancelled'
      end
    end
  end

  describe 'PUT #accept_it' do
    let!(:event) { FactoryBot.create(:event) }

    context 'pending attendance' do
      let(:attendance) { FactoryBot.create(:attendance, event: event, status: 'pending') }
      it 'accepts attendance' do
        put :accept_it, params: { id: attendance.id }, xhr: true
        expect(assigns(:attendance)).to eq attendance
        expect(Attendance.last.status).to eq 'accepted'
      end
    end

    context 'cancelled attendance' do
      let!(:attendance) { FactoryBot.create(:attendance, event: event, status: 'cancelled') }
      it 'keeps cancelled' do
        put :accept_it, params: { id: attendance.id }, xhr: true
        expect(assigns(:attendance)).to eq attendance
        expect(Attendance.last.status).to eq 'cancelled'
      end
    end
  end

  describe 'PUT #recover_it' do
    let!(:event) { FactoryBot.create(:event) }
    context 'when is an individual registration' do
      let(:attendance) { FactoryBot.create(:attendance, event: event, status: 'pending') }
      before do
        Invoice.from_attendance(attendance, 'gateway')
        attendance.cancel
        put :recover_it, params: { id: attendance.id }
      end

      it { expect(Attendance.last.status).to eq 'pending' }
      it { expect(Invoice.last.status).to eq 'pending' }
    end
  end

  describe 'PATCH #dequeue' do
    let!(:event) { FactoryBot.create(:event) }
    context 'when is an individual registration' do
      let(:attendance) { FactoryBot.create(:attendance, event: event, status: 'waiting') }
      before do
        Invoice.from_attendance(attendance, 'gateway')
        patch :dequeue_it, params: { id: attendance.id }
      end

      it 'changes the status and redirects to the attendance page' do
        expect(Attendance.last.status).to eq 'pending'
        expect(Invoice.last.status).to eq 'pending'
        expect(response).to redirect_to attendance_path(attendance)
      end
    end
  end

  describe 'GET #search' do
    let(:admin) { FactoryBot.create(:admin) }
    before { sign_in admin }

    context 'with search parameters, insensitive case' do
      let!(:event) { FactoryBot.create :event }
      context 'and no attendances' do
        before { get :search, params: { event_id: event, search: 'bla' }, xhr: true }
        it { expect(assigns(:attendances_list)).to eq [] }
      end

      context 'with attendances' do
        context 'and searching by first_name' do
          let!(:pending) { FactoryBot.create(:attendance, event: event, status: :pending, first_name: 'bLa') }
          let!(:accepted) { FactoryBot.create(:attendance, event: event, status: :accepted, first_name: 'bLaXPTO') }
          let!(:paid) { FactoryBot.create(:attendance, event: event, status: :paid, first_name: 'bLa') }
          let!(:confirmed) { FactoryBot.create(:attendance, event: event, status: :confirmed, first_name: 'bLa') }
          let!(:cancelled) { FactoryBot.create(:attendance, event: event, status: :cancelled, first_name: 'bLa') }

          let!(:out) { FactoryBot.create(:attendance, event: event, status: :pending, first_name: 'foO') }
          context 'including all statuses' do
            before { get :search, params: { event_id: event, search: 'bla', pending: 'true', accepted: 'true', paid: 'true', confirmed: 'true', cancelled: 'true' }, xhr: true }
            it { expect(assigns(:attendances_list)).to match_array [pending, accepted, paid, confirmed, cancelled] }
          end

          context 'without all statuses' do
            context 'without cancelled' do
              before { get :search, params: { event_id: event, search: 'bla', pending: 'true', accepted: 'true', paid: 'true' }, xhr: true }
              it { expect(assigns(:attendances_list)).to match_array [pending, accepted, paid, confirmed] }
            end
            context 'without cancelled, confirmed and paid' do
              before { get :search, params: { event_id: event, search: 'bla', pending: 'true', accepted: 'true' }, xhr: true }
              it { expect(assigns(:attendances_list)).to match_array [pending, accepted] }
            end
            context 'without cancelled, confirmed, paid and accepted' do
              before { get :search, params: { event_id: event, search: 'bla', pending: 'true' }, xhr: true }
              it { expect(assigns(:attendances_list)).to match_array [pending] }
            end
            context 'without statuses' do
              before { get :search, params: { event_id: event, search: 'bla' }, xhr: true }
              it { expect(assigns(:attendances_list)).to match_array [] }
            end
          end
        end

        context 'including all statuses' do
          let!(:pending) { FactoryBot.create(:attendance, event: event, status: :pending) }
          let!(:accepted) { FactoryBot.create(:attendance, event: event, status: :accepted) }
          let!(:paid) { FactoryBot.create(:attendance, event: event, status: :paid) }
          let!(:confirmed) { FactoryBot.create(:attendance, event: event, status: :confirmed) }
          let!(:cancelled) { FactoryBot.create(:attendance, event: event, status: :cancelled) }
          before { get :search, params: { event_id: event, pending: 'true', accepted: 'true', paid: 'true', confirmed: 'true', cancelled: 'true' }, xhr: true }
          it { expect(assigns(:attendances_list)).to match_array [pending, accepted, paid, confirmed, cancelled] }
        end

        context 'and searching by last_name' do
          let!(:pending) { FactoryBot.create(:attendance, event: event, status: :pending, last_name: 'bLa') }
          let!(:accepted) { FactoryBot.create(:attendance, event: event, status: :accepted, last_name: 'bLaXPTO') }
          let!(:out) { FactoryBot.create(:attendance, event: event, status: :pending, last_name: 'foO') }
          before { get :search, params: { event_id: event, pending: 'true', accepted: 'true', search: 'Bla' }, xhr: true }
          it { expect(assigns(:attendances_list)).to match_array [pending, accepted] }
        end

        context 'and searching by organization' do
          let!(:pending) { FactoryBot.create(:attendance, event: event, status: :pending, organization: 'bLa') }
          let!(:other_pending) { FactoryBot.create(:attendance, event: event, status: :pending, organization: 'bLaXPTO') }
          let!(:out) { FactoryBot.create(:attendance, event: event, status: :pending, organization: 'foO') }
          before { get :search, params: { event_id: event, pending: 'true', search: 'BLA' }, xhr: true }
          it { expect(assigns(:attendances_list)).to match_array [pending, other_pending] }
        end

        context 'and searching by email' do
          let!(:pending) { FactoryBot.create(:attendance, event: event, status: :pending, email: 'bLa@xpto.com.br') }
          let!(:other_pending) { FactoryBot.create(:attendance, event: event, status: :pending, email: 'bLaSBBRUBLES@xpto.com.br') }
          let!(:out) { FactoryBot.create(:attendance, event: event, status: :pending, email: 'foO@xpto.com.br') }
          before { get :search, params: { event_id: event, pending: 'true', search: 'BLA' }, xhr: true }
          it { expect(assigns(:attendances_list)).to match_array [pending, other_pending] }
        end

        context 'and searching by ID' do
          let!(:pending) { FactoryBot.create(:attendance, event: event, first_name: 'bla', last_name: 'xpto', status: :pending, email: 'bLa@xpto.com.br') }
          let!(:out) { FactoryBot.create(:attendance, event: event, first_name: 'foo', last_name: 'bar', status: :pending, email: 'bLaSBBRUBLES@xpto.com.br') }
          before { get :search, params: { event_id: event, pending: 'true', search: pending.id }, xhr: true }
          it { expect(assigns(:attendances_list)).to eq [pending] }
        end
      end
    end

    context 'with csv format' do
      let!(:attendance) { FactoryBot.create(:attendance, event: event, status: :paid, first_name: 'bLa', created_at: 1.day.ago) }
      let!(:other) { FactoryBot.create(:attendance, event: event, status: :paid, first_name: 'bLaXPTO') }
      before { get :search, params: { event_id: event, paid: 'true', format: :csv } }
      it 'returns the attendances in the csv format' do
        expected_disposition = 'attachment; filename="attendances_list.csv"'
        expect(response.body).to eq AttendanceExportService.to_csv([other, attendance])
        expect(response.headers['Content-Disposition']).to eq expected_disposition
      end
    end
  end
end
