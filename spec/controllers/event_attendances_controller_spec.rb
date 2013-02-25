# encoding: UTF-8
require 'spec_helper'

describe EventAttendancesController do
  render_views

  before(:each) do
    @event ||= FactoryGirl.create(:event)
    Event.stubs(:current).returns(@event)
  end
  before :each do
    now = Time.zone.local(2013, 5, 1)
    Time.zone.stubs(:now).returns(now)
  end

  describe "GET new" do
    before do
      controller.current_user = FactoryGirl.create(:user)
    end

    it "should render new template" do
      get :new
      response.should render_template(:new)
    end

    it "should assign current event to attendance" do
      get :new
      assigns(:attendance).event.should == @event
    end

    describe "for individual registration" do
      it "should load registration types without groups or free" do
        get :new
        assigns(:registration_types).should include(RegistrationType.find_by_title('registration_type.individual'))
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
        get :new
        assigns(:registration_types).should include(RegistrationType.find_by_title('registration_type.individual'))
        assigns(:registration_types).should include(RegistrationType.find_by_title('registration_type.free'))
        assigns(:registration_types).size.should == 2
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
        get :new
        assigns(:registration_types).should include(RegistrationType.find_by_title('registration_type.individual'))
        assigns(:registration_types).should include(RegistrationType.find_by_title('registration_type.free'))
        assigns(:registration_types).size.should == 2
      end

      it "should pre select free registration group for attendance and fill email with speakers email" do
        get :new
        assigns(:attendance).registration_type.should == RegistrationType.find_by_title('registration_type.free')
        assigns(:attendance).first_name.should == @user.first_name
        assigns(:attendance).last_name.should == @user.last_name
        assigns(:attendance).organization.should == @user.organization
        assigns(:attendance).email.should == @user.email
      end
    end
  end

  describe "POST create" do
    before(:each) do
      @email = stub(:deliver => true)
      controller.current_user = FactoryGirl.create(:user)
      EmailNotifications.stubs(:registration_pending).returns(@email)
    end

    it "create action should render new template when model is invalid" do
      # +stubs(:valid?).returns(false)+ doesn't work here because
      # inherited_resources does +obj.errors.empty?+ to determine
      # if validation failed
      post :create, :event_attendance => {}
      response.should render_template(:new)
    end

    it "create action should redirect when model is valid" do
      Attendance.any_instance.stubs(:valid?).returns(true)
      post :create
      response.should redirect_to(root_path)
    end

    it "should assign current event to attendance" do
      Attendance.any_instance.stubs(:valid?).returns(true)
      post :create
      assigns(:attendance).event.should == @event
    end

    it "should assign default locale to attendance" do
      Attendance.any_instance.stubs(:valid?).returns(true)
      post :create
      assigns(:attendance).user.default_locale.should == I18n.locale
    end

    describe "for individual registration" do
      it "should send pending registration e-mail" do
        EmailNotifications.expects(:registration_pending).returns(@email)
        Attendance.any_instance.stubs(:valid?).returns(true)
        post :create, :event_attendance => {:registration_type_id => RegistrationType.find_by_title('registration_type.individual').id}
      end

      it "should not allow free registration type" do
        post :create, :event_attendance => {:registration_type_id => RegistrationType.find_by_title('registration_type.free').id}
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
        post :create, :event_attendance => {:registration_type_id => RegistrationType.find_by_title('registration_type.free').id, :email => "another#{@user.email}"}
        response.should redirect_to(root_path)
      end

      it "should not send pending registration e-mail for free registration" do
        EmailNotifications.expects(:registration_pending).never
        Attendance.any_instance.stubs(:valid?).returns(true)
        post :create, :event_attendance => {:registration_type_id => RegistrationType.find_by_title('registration_type.free').id, :email => @user.email}

        response.should redirect_to(root_path)
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
        post :create, :event_attendance => {:registration_type_id => RegistrationType.find_by_title('registration_type.free').id, :email => @user.email}
        response.should redirect_to(root_path)
      end

      it "should not send pending registration e-mail for free registration" do
        EmailNotifications.expects(:registration_pending).never
        Attendance.any_instance.stubs(:valid?).returns(true)
        post :create, :event_attendance => {:registration_type_id => RegistrationType.find_by_title('registration_type.free').id, :email => @user.email}

        response.should redirect_to(root_path)
      end
    end
  end
end