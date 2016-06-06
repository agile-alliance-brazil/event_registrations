describe AttendancesController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }
  let(:event) { FactoryGirl.create(:event, full_price: 930.00) }

  before :each do
    user.add_role :organizer
    user.save
    disable_authorization
    sign_in user
  end

  describe '#index' do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      disable_authorization
    end

    context 'with no search parameter' do
      context 'and no attendances' do
        let!(:event) { FactoryGirl.create(:event) }
        before { get :index, event_id: event, pending: 'pending', accepted: 'accepted', paid: 'paid', confirmed: 'confirmed', cancelled: 'cancelled' }
        it { expect(assigns(:attendances_list)).to eq [] }
      end

      context 'and having attendances' do
        let!(:attendance) { FactoryGirl.create(:attendance) }
        context 'and one attendance, but no association with event' do
          let!(:event) { FactoryGirl.create(:event) }
          before { get :index, event_id: event, pending: 'pending', accepted: 'accepted', paid: 'paid', confirmed: 'confirmed', cancelled: 'cancelled' }
          it { expect(assigns(:attendances_list)).to eq [] }
        end
        context 'and one attendance associated' do
          let!(:event) { FactoryGirl.create(:event, attendances: [attendance]) }
          before { get :index, event_id: event.id, pending: 'pending', accepted: 'accepted', paid: 'paid', confirmed: 'confirmed', cancelled: 'cancelled' }
          it { expect(assigns(:attendances_list)).to match_array [attendance] }
        end
        context 'and one associated and other not' do
          let!(:other_attendance) { FactoryGirl.create(:attendance) }
          let!(:event) { FactoryGirl.create(:event, attendances: [attendance]) }
          before { get :index, event_id: event.id, pending: 'pending', accepted: 'accepted', paid: 'paid', confirmed: 'confirmed', cancelled: 'cancelled' }
          it { expect(assigns(:attendances_list)).to match_array [attendance] }
        end
        context 'and two associated' do
          let!(:other_attendance) { FactoryGirl.create(:attendance) }
          let!(:event) { FactoryGirl.create(:event, attendances: [attendance, other_attendance]) }
          before { get :index, event_id: event.id, pending: 'pending', accepted: 'accepted', paid: 'paid', confirmed: 'confirmed', cancelled: 'cancelled' }
          it { expect(assigns(:attendances_list)).to match_array [attendance, other_attendance] }
        end
        context 'and one attendance in one event and other in other event' do
          let!(:other_attendance) { FactoryGirl.create(:attendance) }
          let!(:event) { FactoryGirl.create(:event, attendances: [attendance]) }
          let!(:other_event) { FactoryGirl.create(:event, attendances: [other_attendance]) }
          before { get :index, event_id: event.id, pending: 'pending', accepted: 'accepted', paid: 'paid', confirmed: 'confirmed', cancelled: 'cancelled' }
          it { expect(assigns(:attendances_list)).to match_array [attendance] }
        end
      end
    end
  end

  describe '#show' do
    context 'with a valid attendance' do
      let!(:event) { FactoryGirl.create(:event) }
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, user: user) }
      let!(:invoice) { Invoice.from_attendance(attendance, Invoice::GATEWAY) }
      before { get :show, id: attendance.id }
      it { expect(assigns[:attendance]).to eq attendance }
      it { expect(response).to be_success }
    end
  end

  describe '#destroy' do
    subject(:attendance) { FactoryGirl.create(:attendance) }

    it 'cancels attendance' do
      Attendance.any_instance.expects(:cancel)
      delete :destroy, id: attendance.id
    end

    it 'not delete attendance' do
      Attendance.any_instance.expects(:destroy).never
      delete :destroy, id: attendance.id
    end

    it 'redirects back to status' do
      delete :destroy, id: attendance.id
      expect(response).to redirect_to(attendance_path(attendance))
    end

    context 'with invoice' do
      it 'cancel the attendance and the invoice' do
        Invoice.from_attendance(attendance, Invoice::GATEWAY)
        delete :destroy, id: attendance.id
        expect(Attendance.last.status).to eq 'cancelled'
        expect(Invoice.last.status).to eq 'cancelled'
      end
    end
  end

  describe '#confirm' do
    context 'responding HTML' do
      let!(:attendance) { FactoryGirl.create(:attendance) }
      it 'confirms attendance' do
        EmailNotifications.stubs(:registration_confirmed).returns(stub(deliver_now: true))
        Attendance.any_instance.expects(:confirm)
        put :confirm, id: attendance.id
      end

      it 'redirects back to status' do
        EmailNotifications.stubs(:registration_confirmed).returns(stub(deliver_now: true))
        put :confirm, id: attendance.id

        expect(response).to redirect_to(attendance_path(attendance))
      end

      it 'notifies airbrake if cannot send email' do
        exception = StandardError.new
        action = :registration_confirmed
        EmailNotifications.expects(action).raises(exception)

        Airbrake.expects(:notify)
                .with(exception.message, action: action, attendance: attendance)

        put :confirm, id: attendance.id

        expect(response).to redirect_to(attendance_path(attendance))
      end

      it 'ignores airbrake errors if cannot send email' do
        exception = StandardError.new
        action = :registration_confirmed
        EmailNotifications.expects(action).raises(exception)
        Airbrake.expects(:notify)
                .with(exception.message, action: action, attendance: attendance)
                .raises(exception)

        put :confirm, id: attendance.id

        expect(response).to redirect_to(attendance_path(attendance))
      end
    end

    context 'responding JS' do
      let!(:attendance) { FactoryGirl.create(:attendance) }

      it 'marks attendance as confirmed, save when this occurs and redirect to attendances index' do
        xhr :put, :confirm, id: attendance.id
        expect(assigns(:attendance)).to eq attendance
        expect(Attendance.last.status).to eq 'confirmed'
      end
    end
  end

  describe '#pay_it' do
    let!(:event) { FactoryGirl.create(:event) }

    context 'pending attendance' do
      context 'grouped attendance' do
        let(:group) { FactoryGirl.create :registration_group }
        let(:attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group, status: 'pending') }
        let!(:invoice) { Invoice.from_attendance(attendance, Invoice::GATEWAY) }
        it 'marks attendance and related invoice as paid, save when this occurs and redirect to attendances index' do
          xhr :put, :pay_it, id: attendance.id
          expect(assigns(:attendance)).to eq attendance
          expect(Attendance.last.status).to eq 'paid'
          expect(Invoice.last.status).to eq 'paid'
        end
      end

      context 'individual attendance' do
        let(:attendance) { FactoryGirl.create(:attendance, event: event, status: 'pending') }
        let!(:invoice) { Invoice.from_attendance(attendance, Invoice::GATEWAY) }
        it 'marks attendance as confirmed and related invoice as paid and redirect to attendances index' do
          EmailNotifications.expects(:registration_confirmed).once
          xhr :put, :pay_it, id: attendance.id
          expect(assigns(:attendance)).to eq attendance
          expect(Attendance.last.status).to eq 'confirmed'
          expect(Invoice.last.status).to eq 'paid'
        end
      end
    end

    context 'cancelled attendance' do
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, status: 'cancelled') }
      it 'doesnt mark as paid and redirect to attendances index with alert' do
        xhr :put, :pay_it, id: attendance.id
        expect(assigns(:attendance)).to eq attendance
        expect(Attendance.last.status).to eq 'cancelled'
      end
    end
  end

  describe '#accept_it' do
    let!(:event) { FactoryGirl.create(:event) }

    context 'pending attendance' do
      let(:attendance) { FactoryGirl.create(:attendance, event: event, status: 'pending') }
      it 'accepts attendance' do
        xhr :put, :accept_it, id: attendance.id
        expect(assigns(:attendance)).to eq attendance
        expect(Attendance.last.status).to eq 'accepted'
      end
    end

    context 'cancelled attendance' do
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, status: 'cancelled') }
      it 'keeps cancelled' do
        xhr :put, :accept_it, id: attendance.id
        expect(assigns(:attendance)).to eq attendance
        expect(Attendance.last.status).to eq 'cancelled'
      end
    end
  end

  describe '#recover_it' do
    let!(:event) { FactoryGirl.create(:event) }
    context 'when is an individual registration' do
      let(:attendance) { FactoryGirl.create(:attendance, event: event, status: 'pending') }
      before do
        Invoice.from_attendance(attendance, Invoice::GATEWAY)
        attendance.cancel
        put :recover_it, id: attendance.id
      end

      it { expect(Attendance.last.status).to eq 'pending' }
      it { expect(Invoice.last.status).to eq 'pending' }
    end
  end

  describe '#dequeue' do
    let!(:event) { FactoryGirl.create(:event) }
    context 'when is an individual registration' do
      let(:attendance) { FactoryGirl.create(:attendance, event: event, status: 'waiting') }
      before do
        Invoice.from_attendance(attendance, Invoice::GATEWAY)
        patch :dequeue_it, id: attendance.id
      end

      it 'changes the status and redirects to the attendance page' do
        expect(Attendance.last.status).to eq 'pending'
        expect(Invoice.last.status).to eq 'pending'
        expect(response).to redirect_to attendance_path(attendance)
      end
    end
  end

  describe '#search' do
    let(:admin) { FactoryGirl.create(:admin) }
    before { sign_in admin }

    context 'with search parameters, insensitive case' do
      let!(:event) { FactoryGirl.create :event }
      context 'and no attendances' do
        before { xhr :get, :search, event_id: event, search: 'bla' }
        it { expect(assigns(:attendances_list)).to eq [] }
      end

      context 'with attendances' do
        context 'and searching by first_name' do
          let!(:pending) { FactoryGirl.create(:attendance, event: event, status: :pending, first_name: 'bLa') }
          let!(:accepted) { FactoryGirl.create(:attendance, event: event, status: :accepted, first_name: 'bLaXPTO') }
          let!(:paid) { FactoryGirl.create(:attendance, event: event, status: :paid, first_name: 'bLa') }
          let!(:confirmed) { FactoryGirl.create(:attendance, event: event, status: :confirmed, first_name: 'bLa') }
          let!(:cancelled) { FactoryGirl.create(:attendance, event: event, status: :cancelled, first_name: 'bLa') }

          let!(:out) { FactoryGirl.create(:attendance, event: event, status: :pending, first_name: 'foO') }
          context 'including all statuses' do
            before { xhr :get, :search, event_id: event, search: 'bla', pending: 'true', accepted: 'true', paid: 'true', confirmed: 'true', cancelled: 'true' }
            it { expect(assigns(:attendances_list)).to match_array [pending, accepted, paid, confirmed, cancelled] }
          end

          context 'without all statuses' do
            context 'without cancelled' do
              before { xhr :get, :search, event_id: event, search: 'bla', pending: 'true', accepted: 'true', paid: 'true' }
              it { expect(assigns(:attendances_list)).to match_array [pending, accepted, paid, confirmed] }
            end
            context 'without cancelled, confirmed and paid' do
              before { xhr :get, :search, event_id: event, search: 'bla', pending: 'true', accepted: 'true' }
              it { expect(assigns(:attendances_list)).to match_array [pending, accepted] }
            end
            context 'without cancelled, confirmed, paid and accepted' do
              before { xhr :get, :search, event_id: event, search: 'bla', pending: 'true' }
              it { expect(assigns(:attendances_list)).to match_array [pending] }
            end
            context 'without statuses' do
              before { xhr :get, :search, event_id: event, search: 'bla' }
              it { expect(assigns(:attendances_list)).to match_array [] }
            end
          end
        end

        context 'including all statuses' do
          let!(:pending) { FactoryGirl.create(:attendance, event: event, status: :pending) }
          let!(:accepted) { FactoryGirl.create(:attendance, event: event, status: :accepted) }
          let!(:paid) { FactoryGirl.create(:attendance, event: event, status: :paid) }
          let!(:confirmed) { FactoryGirl.create(:attendance, event: event, status: :confirmed) }
          let!(:cancelled) { FactoryGirl.create(:attendance, event: event, status: :cancelled) }
          before { xhr :get, :search, event_id: event, pending: 'true', accepted: 'true', paid: 'true', confirmed: 'true', cancelled: 'true' }
          it { expect(assigns(:attendances_list)).to match_array [pending, accepted, paid, confirmed, cancelled] }
        end

        context 'and searching by last_name' do
          let!(:pending) { FactoryGirl.create(:attendance, event: event, status: :pending, last_name: 'bLa') }
          let!(:accepted) { FactoryGirl.create(:attendance, event: event, status: :accepted, last_name: 'bLaXPTO') }
          let!(:out) { FactoryGirl.create(:attendance, event: event, status: :pending, last_name: 'foO') }
          before { xhr :get, :search, event_id: event, pending: 'true', accepted: 'true', search: 'Bla' }
          it { expect(assigns(:attendances_list)).to match_array [pending, accepted] }
        end

        context 'and searching by organization' do
          let!(:pending) { FactoryGirl.create(:attendance, event: event, status: :pending, organization: 'bLa') }
          let!(:other_pending) { FactoryGirl.create(:attendance, event: event, status: :pending, organization: 'bLaXPTO') }
          let!(:out) { FactoryGirl.create(:attendance, event: event, status: :pending, organization: 'foO') }
          before { xhr :get, :search, event_id: event, pending: 'true', search: 'BLA' }
          it { expect(assigns(:attendances_list)).to match_array [pending, other_pending] }
        end

        context 'and searching by email' do
          let!(:pending) { FactoryGirl.create(:attendance, event: event, status: :pending, email: 'bLa@xpto.com.br') }
          let!(:other_pending) { FactoryGirl.create(:attendance, event: event, status: :pending, email: 'bLaSBBRUBLES@xpto.com.br') }
          let!(:out) { FactoryGirl.create(:attendance, event: event, status: :pending, email: 'foO@xpto.com.br') }
          before { xhr :get, :search, event_id: event, pending: 'true', search: 'BLA' }
          it { expect(assigns(:attendances_list)).to match_array [pending, other_pending] }
        end

        context 'and searching by ID' do
          let!(:pending) { FactoryGirl.create(:attendance, event: event, first_name: 'bla', last_name: 'xpto', status: :pending, email: 'bLa@xpto.com.br') }
          let!(:out) { FactoryGirl.create(:attendance, event: event, first_name: 'foo', last_name: 'bar', status: :pending, email: 'bLaSBBRUBLES@xpto.com.br') }
          before { xhr :get, :search, event_id: event, pending: 'true', search: pending.id }
          it { expect(assigns(:attendances_list)).to eq [pending] }
        end
      end
    end

    context 'with csv format' do
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, status: :paid, first_name: 'bLa', created_at: 1.day.ago) }
      let!(:other) { FactoryGirl.create(:attendance, event: event, status: :paid, first_name: 'bLaXPTO') }
      before { get :search, event_id: event, paid: 'true', format: :csv }
      it 'returns the attendances in the csv format' do
        expected_disposition = 'attachment; filename="attendances_list.csv"'
        expect(response.body).to eq AttendanceExportService.to_csv([other, attendance])
        expect(response.headers['Content-Disposition']).to eq expected_disposition
      end
    end
  end
end
