# encoding: UTF-8
require 'spec_helper'

describe EventAttendancesController, type: :controller do
  render_views

  before :each do
    @event = FactoryGirl.create(:event)
    @individual = @event.registration_types.first
    @free = FactoryGirl.create(:registration_type, title: 'registration_type.free', event: @event)
    @manual = FactoryGirl.create(:registration_type, title: 'registration_type.manual', event: @event)
    @speaker = FactoryGirl.create(:registration_type, title: 'registration_type.speaker', event: @event)

    now = Time.zone.local(2013, 5, 1)
    Timecop.freeze(now)

    Attendance.any_instance.stubs(:registration_fee).with(@individual).returns(399)
    Attendance.any_instance.stubs(:registration_fee).with(@free).returns(0)
    Attendance.any_instance.stubs(:registration_fee).with(@speaker).returns(0)
    Attendance.any_instance.stubs(:registration_fee).with(@manual).returns(0)
    Attendance.any_instance.stubs(:registration_fee).with().returns(399)
  end

  after :each do
    Timecop.return
  end

  describe "GET new" do
    before do
      controller.current_user = FactoryGirl.create(:user)
    end

    it "should render new template" do
      get :new, event_id: @event.id
      expect(response).to render_template(:new)
    end

    it "should assign current event to attendance" do
      get :new, event_id: @event.id
      expect(assigns(:attendance).event).to eq(@event)
    end

    describe "for individual registration" do
      it "should load registration types without groups or free" do
        get :new, event_id: @event.id
        expect(assigns(:registration_types)).to include(@individual)
        expect(assigns(:registration_types).size).to eq(1)
      end
    end

    describe "for organizers" do
      before do
        @user = FactoryGirl.create(:user)
        @user.add_role :organizer
        @user.save!
        sign_in @user
        disable_authorization
      end

      it "should load registration types without groups but with free" do
        get :new, event_id: @event.id
        expect(assigns(:registration_types)).to include(@individual)
        expect(assigns(:registration_types)).to include(@free)
        expect(assigns(:registration_types)).to include(@speaker)
        expect(assigns(:registration_types)).to include(@manual)
        expect(assigns(:registration_types).size).to eq(4)
      end
    end
  end

  describe "POST create" do
    let(:user){ FactoryGirl.create(:user) }
    let(:valid_attendance) do
      {
        event_id: @event.id,
        user_id: user.id,
        registration_type_id: @individual.id,
        first_name: user.first_name,
        last_name: user.last_name,
        email: user.email,
        email_confirmation: user.email,
        organization: user.organization,
        phone: user.phone,
        country: user.country,
        state: user.state,
        city: user.city,
        badge_name: user.badge_name,
        cpf: user.cpf,
        gender: user.gender,
        twitter_user: user.twitter_user,
        address: user.address,
        neighbourhood: user.neighbourhood,
        zipcode: user.zipcode
      }
    end
    before(:each) do
      @email = stub(deliver: true)
      controller.current_user = user
      EmailNotifications.stubs(:registration_pending).returns(@email)
    end

    it "should render new template when model is invalid" do
      user.phone = nil # User cannot have everything or we will just pick from there.
      post :create, event_id: @event.id, attendance: {event_id: @event.id}
      expect(response).to render_template(:new)
    end

    it "should redirect when model is valid" do
      Attendance.any_instance.stubs(:valid?).returns(true)
      Attendance.any_instance.stubs(:id).returns(5)
      post :create, event_id: @event.id, attendance: valid_attendance
      expect(response).to redirect_to(attendance_path(5))
    end

    it "should assign current event to attendance" do
      Attendance.any_instance.stubs(:valid?).returns(true)
      post :create, event_id: @event.id, attendance: valid_attendance
      expect(assigns(:attendance).event).to eq(@event)
    end

    it "should notify airbrake if cannot send email" do
      Attendance.any_instance.stubs(:valid?).returns(true)
      exception = StandardError.new
      EmailNotifications.expects(:registration_pending).raises(exception)
      controller.expects(:notify_airbrake).with(exception)
      post :create, event_id: @event.id, attendance: valid_attendance
      expect(assigns(:attendance).event).to eq(@event)
    end

    it "should ignore airbrake errors if cannot send email" do
      Attendance.any_instance.stubs(:valid?).returns(true)
      exception = StandardError.new
      EmailNotifications.expects(:registration_pending).raises(exception)
      controller.expects(:notify_airbrake).with(exception).raises(exception)
      post :create, event_id: @event.id, attendance: valid_attendance
      expect(assigns(:attendance).event).to eq(@event)
    end

    describe "for individual registration" do
      context "cannot add more attendances" do
        before do
          Event.any_instance.stubs(:can_add_attendance?).returns(false)
        end

        it "should redirect to home page with error message when cannot add more attendances" do
          post :create, event_id: @event.id, attendance: {registration_type_id: @individual.id}
          expect(response).to redirect_to(root_path)
          expect(flash[:error]).to eq(I18n.t('flash.attendance.create.max_limit_reached'))
        end

        it "should allow attendance creation if user is organizer" do
          Attendance.any_instance.stubs(:valid?).returns(true)
          Attendance.any_instance.stubs(:id).returns(5)

          user = FactoryGirl.create(:user)
          user.add_role :organizer
          user.save!
          sign_in user
          disable_authorization

          post :create, event_id: @event.id, attendance: {registration_type_id: @individual.id}

          expect(response).to redirect_to(attendance_path(5))
        end
      end

      it "should send pending registration e-mail" do
        Attendance.any_instance.stubs(:valid?).returns(true)
        EmailNotifications.expects(:registration_pending).returns(@email)
        post :create, event_id: @event.id, attendance: {registration_type_id: @individual.id}
      end

      it "should not allow free registration type" do
        Attendance.any_instance.stubs(:valid?).returns(true)
        controller.stubs(:valid_registration_types).returns([@individual, @manual])
        post :create, event_id: @event.id, attendance: {registration_type_id: @free.id}
        expect(response).to render_template(:new)
        expect(flash[:error]).to eq(I18n.t('flash.attendance.create.free_not_allowed'))
      end
    end

    describe "for sponsor registration" do
      before do
        @user = FactoryGirl.create(:user)
        @user.add_role :organizer
        @user.save!
        sign_in @user
        disable_authorization
      end

      it "should allow free registration type no matter the email" do
        Attendance.any_instance.stubs(:valid?).returns(true)
        Attendance.any_instance.stubs(:id).returns(5)

        post :create, event_id: @event.id, attendance: {registration_type_id: @free.id, email: "another#{@user.email}"}
        expect(response).to redirect_to(attendance_path(5))
      end

      it "should not send pending registration e-mail for free registration" do
        EmailNotifications.expects(:registration_pending).never
        Attendance.any_instance.stubs(:valid?).returns(true)
        Attendance.any_instance.stubs(:id).returns(5)

        post :create, event_id: @event.id, attendance: {registration_type_id: @free.id, email: @user.email}

        expect(response).to redirect_to(attendance_path(5))
      end
    end

    describe "for speaker registration" do
      before do
        User.any_instance.stubs(:has_approved_session?).returns(true)
        @user = FactoryGirl.create(:user)
        sign_in @user
        disable_authorization
      end

      it "should allow free registration type only its email" do
        Attendance.any_instance.stubs(:valid?).returns(true)
        Attendance.any_instance.stubs(:id).returns(5)
        post :create, event_id: @event.id, attendance: {registration_type_id: @free.id, email: @user.email}
        expect(response).to redirect_to(attendance_path(5))
      end

      it "should not send pending registration e-mail for free registration" do
        EmailNotifications.expects(:registration_pending).never
        Attendance.any_instance.stubs(:valid?).returns(true)
        Attendance.any_instance.stubs(:id).returns(5)
        post :create, event_id: @event.id, attendance: {registration_type_id: @free.id, email: @user.email}

        expect(response).to redirect_to(attendance_path(5))
      end
    end
  end

  describe '#attendances_list' do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      disable_authorization
    end

    context 'with no search parameter' do

      context 'and no attendances' do
        let!(:event) { FactoryGirl.create(:event) }
        before { get :attendances_list, event_id: event }
        it { expect(assigns(:attendances_list)).to eq [] }
      end

      context 'and having attendances' do
        let!(:attendance) { FactoryGirl.create(:attendance) }
        context 'and one attendance, but no association with event' do
          let!(:event) { FactoryGirl.create(:event) }
          before { get :attendances_list, event_id: event }
          it { expect(assigns(:attendances_list)).to eq [] }
        end
        context 'and one attendance associated' do
          let!(:event) { FactoryGirl.create(:event, attendances: [attendance]) }
          before { get :attendances_list, event_id: event.id }
          it { expect(assigns(:attendances_list)).to match_array [attendance] }
        end
        context 'and one associated and other not' do
          let!(:other_attendance) { FactoryGirl.create(:attendance) }
          let!(:event) { FactoryGirl.create(:event, attendances: [attendance]) }
          before { get :attendances_list, event_id: event.id }
          it { expect(assigns(:attendances_list)).to match_array [attendance] }
        end
        context 'and two associated' do
          let!(:other_attendance) { FactoryGirl.create(:attendance) }
          let!(:event) { FactoryGirl.create(:event, attendances: [attendance, other_attendance]) }
          before { get :attendances_list, event_id: event.id }
          it { expect(assigns(:attendances_list)).to match_array [attendance, other_attendance] }
        end
        context 'and one active and other inactive' do
          let!(:other_attendance) { FactoryGirl.create(:attendance, status: 'cancelled') }
          let!(:event) { FactoryGirl.create(:event, attendances: [attendance, other_attendance]) }
          before { get :attendances_list, event_id: event.id }
          it { expect(assigns(:attendances_list)).to match_array [attendance] }
        end
        context 'and two inactives' do
          let!(:inactive_attendance) { FactoryGirl.create(:attendance, status: 'cancelled') }
          let!(:other_attendance) { FactoryGirl.create(:attendance, status: 'cancelled') }
          let!(:event) { FactoryGirl.create(:event, attendances: [inactive_attendance, other_attendance]) }
          before { get :attendances_list, event_id: event.id }
          it { expect(assigns(:attendances_list)).to match_array [] }
        end
      end
    end

    context 'with search parameters, insensitive case' do
      let!(:event) { FactoryGirl.create(:event) }
      context 'and no attendances' do
        before { get :attendances_list, event_id: event, search: 'bla' }
        it { expect(assigns(:attendances_list)).to eq [] }
      end

      context 'and having attendances' do
        context 'and one attendance' do
          context 'and matching first name' do
            let!(:attendance) { FactoryGirl.create(:attendance, first_name: 'xpto', last_name: 'bla', event: event) }
            before { get :attendances_list, event_id: event, search: 'xPTo' }
            it { expect(assigns(:attendances_list)).to match_array [attendance] }
          end
          context 'and matching last name' do
            let!(:attendance) { FactoryGirl.create(:attendance, first_name: 'xpto', last_name: 'bla', event: event) }
            before { get :attendances_list, event_id: event, search: 'bLa' }
            it { expect(assigns(:attendances_list)).to match_array [attendance] }
          end
          context 'and matching organization' do
            let!(:attendance) { FactoryGirl.create(:attendance, organization: 'bla', event: event) }
            before { get :attendances_list, event_id: event, search: 'bLa' }
            it { expect(assigns(:attendances_list)).to match_array [attendance] }
          end
          context 'and matching email' do
            let!(:attendance) { FactoryGirl.create(:attendance, email: 'bla@xpto.com', email_confirmation: 'bla@xpto.com', event: event) }
            before { get :attendances_list, event_id: event, search: 'bLa' }
            it { expect(assigns(:attendances_list)).to match_array [attendance] }
          end
        end

        context 'and two not matching attendances' do
          let!(:attendance) { FactoryGirl.create(:attendance, first_name: 'xpto', last_name: 'bla', event: event) }
          let!(:other_attendance) { FactoryGirl.create(:attendance, first_name: 'foo', last_name: 'bar', event: event) }
          before { get :attendances_list, event_id: event, search: 'bLa' }
          it { expect(assigns(:attendances_list)).to match_array [attendance] }
        end

        context 'and two matching attendances on same field' do
          let!(:attendance) { FactoryGirl.create(:attendance, first_name: 'xpto', last_name: 'bla', event: event) }
          let!(:other_attendance) { FactoryGirl.create(:attendance, first_name: 'xpto', last_name: 'bar', event: event) }
          before { get :attendances_list, event_id: event, search: 'xpto' }
          it { expect(assigns(:attendances_list)).to match_array [attendance, other_attendance] }
        end

        context 'and two matching attendances on different fields' do
          let!(:attendance) { FactoryGirl.create(:attendance,
                                                 first_name: 'xpto',
                                                 last_name: 'bla',
                                                 email: 'foo@bar.com',
                                                 email_confirmation: 'foo@bar.com',
                                                 event: event) }
          let!(:other_attendance) { FactoryGirl.create(:attendance, first_name: 'foo', last_name: 'bar', event: event) }
          before { get :attendances_list, event_id: event, search: 'foo' }
          it { expect(assigns(:attendances_list)).to match_array [attendance, other_attendance] }
        end
      end
    end
  end
end
