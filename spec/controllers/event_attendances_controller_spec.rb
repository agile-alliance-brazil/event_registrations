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
    Attendance.any_instance.stubs(:registration_fee).with.returns(399)
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

  describe '#create' do
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

    it 'renders new template when model is invalid' do
      user.phone = nil # User cannot have everything or we will just pick from there.
      # I think we need to consolidate all user and attendee information
      post :create, event_id: @event.id, attendance: {event_id: @event.id}
      expect(response).to render_template(:new)
    end

    it 'redirects when model is valid' do
      Attendance.any_instance.stubs(:valid?).returns(true)
      Attendance.any_instance.stubs(:id).returns(5)
      post :create, event_id: @event.id, attendance: valid_attendance
      expect(response).to redirect_to(attendance_path(5))
    end

    it 'assigns current event to attendance' do
      Attendance.any_instance.stubs(:valid?).returns(true)
      post :create, event_id: @event.id, attendance: valid_attendance
      expect(assigns(:attendance).event).to eq @event
    end

    context 'event value for attendance' do
      before { Timecop.return }
      context 'with no period, quotas or groups' do
        before { post :create, event_id: @event.id, attendance: valid_attendance }
        it { expect(assigns(:attendance).registration_value).to eq @event.full_price }
      end

      context 'with no period or quotas, but with a valid group' do
        let(:group) { FactoryGirl.create(:registration_group, event: @event, discount: 30) }
        before { post :create, event_id: @event.id, registration_token: group.token, attendance: valid_attendance }
        it { expect(assigns(:attendance).registration_value).to eq @event.full_price * 0.7 }
      end

      context 'with period and no quotas or group' do
        let(:event) { Event.create!(name: 'Agile Brazil 2015', price_table_link: 'http://localhost:9292/link', full_price: 840.00) }
        let!(:registration_type) { FactoryGirl.create :registration_type, event: event }
        let!(:full_registration_period) { RegistrationPeriod.create!(start_at: 2.days.ago, end_at: 1.day.from_now, event: event) }
        let!(:price) { RegistrationPrice.create!(registration_type: registration_type, registration_period: full_registration_period, value: 740.00) }

        before { post :create, event_id: event.id, attendance: valid_attendance }
        it { expect(assigns(:attendance).registration_value).to eq 740.00 }
      end
    end

    it 'notifies airbrake if cannot send email' do
      Attendance.any_instance.stubs(:valid?).returns(true)
      exception = StandardError.new
      EmailNotifications.expects(:registration_pending).raises(exception)
      controller.expects(:notify_airbrake).with(exception)
      post :create, event_id: @event.id, attendance: valid_attendance
      expect(assigns(:attendance).event).to eq(@event)
    end

    it 'should ignore airbrake errors if cannot send email' do
      Attendance.any_instance.stubs(:valid?).returns(true)
      exception = StandardError.new
      EmailNotifications.expects(:registration_pending).raises(exception)
      controller.expects(:notify_airbrake).with(exception).raises(exception)
      post :create, event_id: @event.id, attendance: valid_attendance
      expect(assigns(:attendance).event).to eq(@event)
    end

    context 'for individual registration' do
      context 'cannot add more attendances' do
        before { Event.any_instance.stubs(:can_add_attendance?).returns(false) }

        it 'redirects to home page with error message when cannot add more attendances' do
          post :create, event_id: @event.id, attendance: {registration_type_id: @individual.id}
          expect(response).to redirect_to(root_path)
          expect(flash[:error]).to eq(I18n.t('flash.attendance.create.max_limit_reached'))
        end

        it 'allows attendance creation if user is organizer' do
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

      context 'with no token' do
        let!(:period) { RegistrationPeriod.create(event: @event, start_at: 1.month.ago, end_at: 1.month.from_now) }
        let!(:price) { RegistrationPrice.create!(registration_type: @individual, registration_period: period, value: 100.00) }
        subject(:attendance) { assigns(:attendance) }
        before { post :create, event_id: @event.id, attendance: { registration_type_id: @individual.id } }
        it { expect(attendance.registration_group).to be_nil }
      end

      context 'with registration token' do
        let!(:period) { RegistrationPeriod.create(event: @event, start_at: 1.month.ago, end_at: 1.month.from_now) }
        let!(:price) { RegistrationPrice.create!(registration_type: @individual, registration_period: period, value: 100.00) }
        subject(:attendance) { assigns(:attendance) }

        context 'an invalid' do
          context 'and one event' do
            before { post :create, event_id: @event.id, registration_token: 'xpto', attendance: { registration_type_id: @individual.id } }
            it { expect(attendance.registration_group).to be_nil }
          end

          context 'and with a registration token from other event' do
            let(:other_event) { FactoryGirl.create :event }
            let!(:group) { FactoryGirl.create(:registration_group, event: @event) }
            let!(:other_group) { FactoryGirl.create(:registration_group, event: other_event) }
            before { post :create, event_id: @event.id, registration_token: other_group.token, attendance: { registration_type_id: @individual.id } }
            it { expect(attendance.registration_group).to be_nil }
          end

          context 'and with a registration token with invalid invoice status' do
            let!(:group) { FactoryGirl.create(:registration_group, event: @event) }
            let!(:invoice) { FactoryGirl.create :invoice, registration_group: group, status: Invoice::PAID }
            before { post :create, event_id: @event.id, registration_token: group.token, attendance: { registration_type_id: @individual.id } }
            it { expect(attendance.registration_group).to be_nil }
          end
        end

        context 'a valid' do
          let!(:group) { FactoryGirl.create(:registration_group, event: @event) }
          before { post :create, event_id: @event.id, registration_token: group.token, attendance: { registration_type_id: @individual.id } }
          it { expect(attendance.registration_group).to eq group }
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
