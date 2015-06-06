describe AttendancesController, type: :controller do
  let(:user) { FactoryGirl.create(:user) }
  let(:event) { Event.create!(name: Faker::Company.name, price_table_link: 'http://localhost:9292/link', full_price: 930.00) }
  let!(:registration_type) { FactoryGirl.create :registration_type, event: event }
  let!(:free) { FactoryGirl.create(:registration_type, title: 'registration_type.free', event: event) }
  let!(:manual) { FactoryGirl.create(:registration_type, title: 'registration_type.manual', event: event) }

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
        before { get :index, event_id: event }
        it { expect(assigns(:attendances_list)).to eq [] }
      end

      context 'and having attendances' do
        let!(:attendance) { FactoryGirl.create(:attendance) }
        context 'and one attendance, but no association with event' do
          let!(:event) { FactoryGirl.create(:event) }
          before { get :index, event_id: event }
          it { expect(assigns(:attendances_list)).to eq [] }
        end
        context 'and one attendance associated' do
          let!(:event) { FactoryGirl.create(:event, attendances: [attendance]) }
          before { get :index, event_id: event.id }
          it { expect(assigns(:attendances_list)).to match_array [attendance] }
        end
        context 'and one associated and other not' do
          let!(:other_attendance) { FactoryGirl.create(:attendance) }
          let!(:event) { FactoryGirl.create(:event, attendances: [attendance]) }
          before { get :index, event_id: event.id }
          it { expect(assigns(:attendances_list)).to match_array [attendance] }
        end
        context 'and two associated' do
          let!(:other_attendance) { FactoryGirl.create(:attendance) }
          let!(:event) { FactoryGirl.create(:event, attendances: [attendance, other_attendance]) }
          before { get :index, event_id: event.id }
          it { expect(assigns(:attendances_list)).to match_array [attendance, other_attendance] }
        end
        context 'and one attendance in one event and other in other event' do
          let!(:other_attendance) { FactoryGirl.create(:attendance) }
          let!(:event) { FactoryGirl.create(:event, attendances: [attendance]) }
          let!(:other_event) { FactoryGirl.create(:event, attendances: [other_attendance]) }
          before { get :index, event_id: event.id }
          it { expect(assigns(:attendances_list)).to match_array [attendance] }
        end
      end
    end

    context 'with search parameters, insensitive case' do
      let!(:event) { FactoryGirl.create(:event) }
      context 'and no attendances' do
        before { get :index, event_id: event, search: 'bla' }
        it { expect(assigns(:attendances_list)).to eq [] }
      end
    end
  end

  describe '#show' do
    context 'with a valid attendance' do
      let!(:event) { FactoryGirl.create(:event) }
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, user: user) }
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
      EmailNotifications.expects(:registration_confirmed).raises(exception)

      Airbrake.expects(:notify).with(exception)

      put :confirm, id: attendance.id

      expect(response).to redirect_to(attendance_path(attendance))
    end

    it 'ignores airbrake errors if cannot send email' do
      exception = StandardError.new
      EmailNotifications.expects(:registration_confirmed).raises(exception)
      Airbrake.expects(:notify).with(exception).raises(exception)

      put :confirm, id: attendance.id

      expect(response).to redirect_to(attendance_path(attendance))
    end
  end

  describe '#pay_it' do
    let!(:event) { FactoryGirl.create(:event) }

    context 'pending attendance' do
      let(:attendance) { FactoryGirl.create(:attendance, event: event, status: 'pending') }
      let!(:invoice) { Invoice.from_attendance(attendance, Invoice::GATEWAY) }
      it 'marks attendance and related invoice as paid, save when this occurs and redirect to attendances index' do
        put :pay_it, id: attendance.id
        expect(response).to redirect_to attendances_path(event_id: event.id)
        expect(flash[:notice]).to eq I18n.t('flash.attendance.payment.success')
        expect(Attendance.last.status).to eq 'paid'
      end
    end

    context 'cancelled attendance' do
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, status: 'cancelled') }
      it 'doesnt mark as paid and redirect to attendances index with alert' do
        put :pay_it, id: attendance.id
        expect(response).to redirect_to attendances_path(event_id: event.id)
        expect(flash[:alert]).to eq I18n.t('flash.attendance.payment.error')
        expect(Attendance.last.status).to eq 'cancelled'
      end
    end
  end

  describe '#accept_it' do
    let!(:event) { FactoryGirl.create(:event) }

    context 'pending attendance' do
      let(:attendance) { FactoryGirl.create(:attendance, event: event, status: 'pending') }
      it 'accepts attendance' do
        put :accept_it, id: attendance.id
        expect(response).to redirect_to attendances_path(event_id: event.id)
        expect(flash[:notice]).to eq I18n.t('flash.attendance.accepted.success')
        expect(Attendance.last.status).to eq 'accepted'
      end
    end

    context 'cancelled attendance' do
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, status: 'cancelled') }
      it 'keeps cancelled' do
        put :accept_it, id: attendance.id
        expect(response).to redirect_to attendances_path(event_id: event.id)
        expect(Attendance.last.status).to eq 'cancelled'
      end
    end
  end
end
