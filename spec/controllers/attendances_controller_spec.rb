# encoding: UTF-8
require 'spec_helper'

describe AttendancesController do
  render_views

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
      response.should render_template(:new)
    end

    it "should assign current event to attendance" do
      get :new, event_id: @event.id
      assigns(:attendance).event.should == @event
    end

    describe "for individual registration" do
      it "should load registration types without groups or free" do
        get :new, event_id: @event.id
        assigns(:registration_types).should include(@individual)
        assigns(:registration_types).size.should == 1
      end
    end

    describe "for sponsors" do
      before do
        @user = FactoryGirl.create(:user)
        @user.add_role :organizer
        @user.save!
        sign_in @user
        disable_authorization
      end

      it "should load registration types without groups but with free" do
        get :new, event_id: @event.id
        assigns(:registration_types).should include(@individual)
        assigns(:registration_types).should include(@free)
        assigns(:registration_types).should include(@manual)
        assigns(:registration_types).size.should == 3
      end
    end

    describe "for speakers" do
      before do
        User.any_instance.stubs(:has_approved_session?).returns(true)
        @user = FactoryGirl.create(:user)
        sign_in @user
        disable_authorization
      end

      it "should load registration types without groups but with free" do
        get :new, event_id: @event.id
        assigns(:registration_types).should include(@individual)
        assigns(:registration_types).should include(@free)
        assigns(:registration_types).size.should == 2
      end

      it "should pre select free registration group for attendance and fill email with speakers email" do
        get :new, event_id: @event.id
        assigns(:attendance).registration_type.should == @free
        assigns(:attendance).first_name.should == @user.first_name
        assigns(:attendance).last_name.should == @user.last_name
        assigns(:attendance).organization.should == @user.organization
        assigns(:attendance).email.should == @user.email
      end
    end
  end

  describe "PUT confirm" do
    before(:each) do
      user = FactoryGirl.create(:user)
      user.add_role :organizer
      user.save
      sign_in user
      disable_authorization

      controller.current_user = user

      @attendance = FactoryGirl.build(:attendance, user: user, id: 5)

      Attendance.stubs(:find).with(@attendance.id.to_s).returns(@attendance)
    end

    it "should confirm attendance" do
      EmailNotifications.stubs(:registration_confirmed).returns(stub(deliver: true))
      @attendance.expects(:confirm)

      put :confirm, event_id: @event.id, id: @attendance.id
    end

    it "should redirect back to status" do
      EmailNotifications.stubs(:registration_confirmed).returns(stub(deliver: true))
      put :confirm, event_id: @event.id, id: @attendance.id

      response.should redirect_to(attendance_status_path(5))
    end

    it "should notify airbrake if cannot send email" do
      exception = StandardError.new
      EmailNotifications.expects(:registration_confirmed).raises(exception)

      Airbrake.expects(:notify).with(exception)

      put :confirm, event_id: @event.id, id: @attendance.id

      response.should redirect_to(attendance_status_path(5))
    end

    it "should ignore airbrake errors if cannot send email" do
      exception = StandardError.new
      EmailNotifications.expects(:registration_confirmed).raises(exception)
      Airbrake.expects(:notify).with(exception).raises(exception)

      put :confirm, event_id: @event.id, id: @attendance.id

      response.should redirect_to(attendance_status_path(5))
    end
  end

  describe "POST create" do
    before(:each) do
      @email = stub(deliver: true)
      controller.current_user = FactoryGirl.create(:user)
      EmailNotifications.stubs(:registration_pending).returns(@email)
    end

    it "should render new template when model is invalid" do
      # +stubs(:valid?).returns(false)+ doesn't work here because
      # inherited_resources does +obj.errors.empty?+ to determine
      # if validation failed
      post :create, event_id: @event.id, attendance: {}
      response.should render_template(:new)
    end

    it "should redirect when model is valid" do
      Attendance.any_instance.stubs(:valid?).returns(true)
      Attendance.any_instance.stubs(:id).returns(5)
      post :create, event_id: @event.id
      response.should redirect_to(attendance_status_path(5))
    end

    it "should assign current event to attendance" do
      Attendance.any_instance.stubs(:valid?).returns(true)
      post :create, event_id: @event.id
      assigns(:attendance).event.should == @event
    end

    it "should notify airbrake if cannot send email" do
      Attendance.any_instance.stubs(:valid?).returns(true)
      exception = StandardError.new
      EmailNotifications.expects(:registration_pending).raises(exception)
      controller.expects(:notify_airbrake).with(exception)
      post :create, :event_id => @event.id
      assigns(:attendance).event.should == @event
    end

    it "should ignore airbrake errors if cannot send email" do
      Attendance.any_instance.stubs(:valid?).returns(true)
      exception = StandardError.new
      EmailNotifications.expects(:registration_pending).raises(exception)
      controller.expects(:notify_airbrake).with(exception).raises(exception)
      post :create, :event_id => @event.id
      assigns(:attendance).event.should == @event
    end

    describe "for individual registration" do
      context "cannot add more attendances" do
        before do
          Event.any_instance.stubs(:can_add_attendance?).returns(false)
        end

        it "should redirect to home page with error message when cannot add more attendances" do
          post :create, event_id: @event.id, attendance: {registration_type_id: @individual.id}
          response.should redirect_to(root_path)
          flash[:error].should == I18n.t('flash.attendance.create.max_limit_reached')
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

          response.should redirect_to(attendance_status_path(5))
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
        response.should render_template(:new)
        flash[:error].should == I18n.t('flash.attendance.create.free_not_allowed')
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
        response.should redirect_to(attendance_status_path(5))
      end

      it "should not send pending registration e-mail for free registration" do
        EmailNotifications.expects(:registration_pending).never
        Attendance.any_instance.stubs(:valid?).returns(true)
        Attendance.any_instance.stubs(:id).returns(5)

        post :create, event_id: @event.id, attendance: {registration_type_id: @free.id, email: @user.email}

        response.should redirect_to(attendance_status_path(5))
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
        response.should redirect_to(attendance_status_path(5))
      end

      it "should not send pending registration e-mail for free registration" do
        EmailNotifications.expects(:registration_pending).never
        Attendance.any_instance.stubs(:valid?).returns(true)
        Attendance.any_instance.stubs(:id).returns(5)
        post :create, event_id: @event.id, attendance: {registration_type_id: @free.id, email: @user.email}

        response.should redirect_to(attendance_status_path(5))
      end
    end
  end
end
