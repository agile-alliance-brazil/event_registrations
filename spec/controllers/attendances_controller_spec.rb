describe AttendancesController, type: :controller do
  before :each do
    @event = FactoryGirl.create(:event)
    @individual = @event.registration_types.first
    @free = FactoryGirl.create(:registration_type, title: 'registration_type.free', event: @event)
    @manual = FactoryGirl.create(:registration_type, title: 'registration_type.manual', event: @event)

    now = Time.zone.local(2013, 5, 1)
    Timecop.freeze(now)

    Attendance.any_instance.stubs(:registration_fee).with(@individual).returns(399)
    Attendance.any_instance.stubs(:registration_fee).with(@free).returns(0)
    Attendance.any_instance.stubs(:registration_fee).with(@manual).returns(0)
    Attendance.any_instance.stubs(:registration_fee).with.returns(399)

    user = FactoryGirl.create(:user)
    user.add_role :organizer
    user.save
    disable_authorization

    sign_in user

    @attendance = FactoryGirl.create(:attendance, user: user)
    Attendance.stubs(:find).with(@attendance.id.to_s).returns(@attendance)
  end

  after :each do
    Timecop.return
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

  describe "GET show" do
    it "should set attendance variable" do
      get :show, id: @attendance.id

      expect(assigns[:attendance]).to eq(@attendance)
    end
    it "should respond to json" do
      get :show, id: @attendance.id, format: :json

      expect(response).to be_success      
    end
  end

  describe "DELETE destroy" do
    it "should cancel attendance" do
      @attendance.expects(:cancel)

      delete :destroy, id: @attendance.id
    end

    it "should not delete attendance" do
      @attendance.expects(:destroy).never

      delete :destroy, id: @attendance.id
    end

    it "should redirect back to status" do
      delete :destroy, id: @attendance.id

      expect(response).to redirect_to(attendance_path(@attendance))
    end
  end

  describe "PUT confirm" do
    it "should confirm attendance" do
      EmailNotifications.stubs(:registration_confirmed).returns(stub(deliver_now: true))
      @attendance.expects(:confirm)

      put :confirm, id: @attendance.id
    end

    it "should redirect back to status" do
      EmailNotifications.stubs(:registration_confirmed).returns(stub(deliver_now: true))
      put :confirm, id: @attendance.id

      expect(response).to redirect_to(attendance_path(@attendance))
    end

    it "should notify airbrake if cannot send email" do
      exception = StandardError.new
      EmailNotifications.expects(:registration_confirmed).raises(exception)

      Airbrake.expects(:notify).with(exception)

      put :confirm, id: @attendance.id

      expect(response).to redirect_to(attendance_path(@attendance))
    end

    it "should ignore airbrake errors if cannot send email" do
      exception = StandardError.new
      EmailNotifications.expects(:registration_confirmed).raises(exception)
      Airbrake.expects(:notify).with(exception).raises(exception)

      put :confirm, id: @attendance.id

      expect(response).to redirect_to(attendance_path(@attendance))
    end
  end
end
