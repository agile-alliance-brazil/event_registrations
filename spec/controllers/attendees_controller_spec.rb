# encoding: UTF-8
require 'spec_helper'

describe AttendeesController do
  render_views

  before(:each) do
    @event ||= FactoryGirl.create(:event)
  end

  describe "GET index" do
    it "should redirect to root when not authorized" do
      get :index
      response.should redirect_to(new_attendee_path)
    end

    describe "should present a summary of all attendees states for authorized users" do
      before do
        @user = FactoryGirl.create(:user)
        sign_in @user
        disable_authorization
      end

      it "should assign all attendees and course attendances to registrar users" do
        @user.add_role :registrar
        @user.save!

        attendee = FactoryGirl.create(:attendee)
        attendees = [attendee]
        course_attendances = [FactoryGirl.create(:course_attendance, :attendee => attendee)]
        Attendee.expects(:all).returns(attendees)
        CourseAttendance.expects(:all).returns(course_attendances)
        get :index
        assigns(:attendees).should == attendees
        assigns(:course_attendances).should == course_attendances
      end

      it "should assign all attendees and course attendances to admin" do
        @user.add_role :admin
        @user.save!

        attendee = FactoryGirl.create(:attendee)
        attendees = [attendee]
        course_attendances = [FactoryGirl.create(:course_attendance, :attendee => attendee)]
        Attendee.expects(:all).returns(attendees)
        CourseAttendance.expects(:all).returns(course_attendances)
        get :index
        assigns(:attendees).should == attendees
        assigns(:course_attendances).should == course_attendances
      end
    end
  end

  before :each do
    now = Time.zone.local(2011, 4, 25)
    Time.zone.stubs(:now).returns(now)
  end

  describe "GET new" do
    it "should render new template" do
      get :new
      response.should render_template(:new)
    end

    it "should assign current event to attendee registration" do
      get :new
      assigns(:attendee).event.should == @event
    end

    it "should assign default locale to attendee registration" do
      get :new
      assigns(:attendee).default_locale.should == I18n.locale
    end

    describe "for individual registration" do
      it "should render flash news" do
        get :new
        flash[:news].should_not be_nil
      end

      it "should load registration types without groups or free" do
        get :new
        assigns(:registration_types).should include(RegistrationType.find_by_title('registration_type.individual'))
        assigns(:registration_types).should include(RegistrationType.find_by_title('registration_type.student'))
        assigns(:registration_types).size.should == 2
      end
    end

    describe "for sponsors" do
      before do
        @user = FactoryGirl.create(:user)
        @user.add_role :registrar
        @user.save!
        sign_in @user
        disable_authorization
      end

      it "should load registration types without groups but with free" do
        get :new
        assigns(:registration_types).should include(RegistrationType.find_by_title('registration_type.individual'))
        assigns(:registration_types).should include(RegistrationType.find_by_title('registration_type.student'))
        assigns(:registration_types).should include(RegistrationType.find_by_title('registration_type.free'))
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
        get :new
        assigns(:registration_types).should include(RegistrationType.find_by_title('registration_type.individual'))
        assigns(:registration_types).should include(RegistrationType.find_by_title('registration_type.student'))
        assigns(:registration_types).should include(RegistrationType.find_by_title('registration_type.free'))
        assigns(:registration_types).size.should == 3
      end

      it "should pre select free registration group for attendee and fill email with speakers email" do
        get :new
        assigns(:attendee).registration_type.should == RegistrationType.find_by_title('registration_type.free')
        assigns(:attendee).first_name.should == @user.first_name
        assigns(:attendee).last_name.should == @user.last_name
        assigns(:attendee).organization.should == @user.organization
        assigns(:attendee).email.should == @user.email
      end
    end

    describe "for group registration" do
      before do
        @registration_group ||= FactoryGirl.create(:registration_group)
      end

      it "should not render flash news" do
        get :new, :registration_group_id => @registration_group.id
        flash[:news].should be_nil
      end

      it "should load registration types except free" do
        get :new, :registration_group_id => @registration_group.id
        assigns(:registration_types).should include(RegistrationType.find_by_title('registration_type.individual'))
        assigns(:registration_types).should include(RegistrationType.find_by_title('registration_type.group'))
        assigns(:registration_types).should include(RegistrationType.find_by_title('registration_type.student'))
        assigns(:registration_types).size.should == 3
      end

      it "should set registration_type to group" do
        get :new, :registration_group_id => @registration_group.id
        assigns(:attendee).registration_type.should == RegistrationType.find_by_title('registration_type.group')
      end

      it "should pre select free registration group for attendee with session approved" do
        User.any_instance.stubs(:has_approved_session?).returns(true)
        sign_in FactoryGirl.create(:user)
        disable_authorization
        get :new, :registration_group_id => @registration_group.id
        assigns(:attendee).registration_type.should == RegistrationType.find_by_title('registration_type.free')
      end

      it "should set organization name from registration group" do
        get :new, :registration_group_id => @registration_group.id
        assigns(:attendee).organization.should == @registration_group.name
      end

      it "should not allow creating more attendees than allowed on registration group" do
        RegistrationGroup.any_instance.stubs(:total_attendees).returns(1)
        RegistrationGroup.any_instance.stubs(:attendees).returns([FactoryGirl.create(:attendee)])
        get :new, :registration_group_id => @registration_group.id
        flash[:error].should_not be_nil
        response.should redirect_to(root_path)
      end
    end

  end

  describe "POST create" do
    before(:each) do
      @email = stub(:deliver => true)
      EmailNotifications.stubs(:registration_pending).returns(@email)
      EmailNotifications.stubs(:registration_group_attendee).returns(@email)
      EmailNotifications.stubs(:registration_group_pending).returns(@email)
    end

    it "create action should render new template when model is invalid" do
      # +stubs(:valid?).returns(false)+ doesn't work here because
      # inherited_resources does +obj.errors.empty?+ to determine
      # if validation failed
      post :create, :attendee => {}
      response.should render_template(:new)
    end

    it "create action should redirect when model is valid" do
      Attendee.any_instance.stubs(:valid?).returns(true)
      post :create
      response.should redirect_to(root_path)
    end

    it "should assign current event to attendee registration" do
      Attendee.any_instance.stubs(:valid?).returns(true)
      post :create
      assigns(:attendee).event.should == @event
    end

    it "should assign default locale to attendee registration" do
      Attendee.any_instance.stubs(:valid?).returns(true)
      post :create
      assigns(:attendee).default_locale.should == I18n.locale
    end

    describe "for individual registration" do
      it "should send pending registration e-mail" do
        EmailNotifications.expects(:registration_pending).returns(@email)
        Attendee.any_instance.stubs(:valid?).returns(true)
        post :create, :attendee => {:registration_type_id => RegistrationType.find_by_title('registration_type.individual').id}
      end

      it "should not allow free registration type" do
        post :create, :attendee => {:registration_type_id => RegistrationType.find_by_title('registration_type.free').id}
        response.should render_template(:new)
        flash[:error].should == I18n.t('flash.attendee.create.free_not_allowed')
      end
    end

    describe "for sponsor registration" do
      before do
        @user = FactoryGirl.create(:user)
        @user.add_role :registrar
        @user.save!
        sign_in @user
        disable_authorization
      end

      it "should allow free registration type no matter the email" do
        Attendee.any_instance.stubs(:valid?).returns(true)
        post :create, :attendee => {:registration_type_id => RegistrationType.find_by_title('registration_type.free').id, :email => "another"+@user.email}
        response.should redirect_to(root_path)
      end

      it "should not send pending registration e-mail for free registration without courses" do
        EmailNotifications.expects(:registration_pending).never
        Attendee.any_instance.stubs(:valid?).returns(true)
        post :create, :attendee => {:registration_type_id => RegistrationType.find_by_title('registration_type.free').id, :email => @user.email}

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

      it "should not allow free registration type for another email" do
        Attendee.any_instance.stubs(:valid?).returns(true)
        post :create, :attendee => {:registration_type_id => RegistrationType.find_by_title('registration_type.free').id, :email => "another"+@user.email}

        response.should render_template(:new)
        flash[:error].should == I18n.t('flash.attendee.create.free_not_allowed')
      end

      it "should allow free registration type only its email" do
        Attendee.any_instance.stubs(:valid?).returns(true)
        post :create, :attendee => {:registration_type_id => RegistrationType.find_by_title('registration_type.free').id, :email => @user.email}
        response.should redirect_to(root_path)
      end

      it "should not send pending registration e-mail for free registration without courses" do
        EmailNotifications.expects(:registration_pending).never
        Attendee.any_instance.stubs(:valid?).returns(true)
        post :create, :attendee => {:registration_type_id => RegistrationType.find_by_title('registration_type.free').id, :email => @user.email}

        response.should redirect_to(root_path)
      end
    end

    describe "for group registration" do
      before do
        @registration_group ||= FactoryGirl.create(:registration_group)
        Attendee.any_instance.stubs(:valid?).returns(true)
      end

      it "should send attendee registration e-mail" do
        EmailNotifications.expects(:registration_group_attendee).returns(@email)
        post :create, :registration_group_id => @registration_group.id
      end

      it "should send pending registration e-mail when group is complete" do
        RegistrationGroup.any_instance.stubs(:complete).returns(true)
        EmailNotifications.expects(:registration_group_pending).returns(@email)
        post :create, :registration_group_id => @registration_group.id
      end

      it "should redirect to new attendee when group is incomplete" do
        RegistrationGroup.any_instance.stubs(:complete).returns(false)
        post :create, :registration_group_id => @registration_group.id
        response.should redirect_to(new_registration_group_attendee_path(@registration_group))
      end

      it "should redirect to root when group is complete" do
        RegistrationGroup.any_instance.stubs(:complete).returns(true)
        post :create, :registration_group_id => @registration_group.id
        response.should redirect_to(root_path)
      end

      context "when signed in" do
        before do
          @user = FactoryGirl.create(:user)
          sign_in @user
          disable_authorization
        end

        it "should not allow free registration for author with approved session" do
          User.any_instance.stubs(:has_approved_session?).returns(true)
          post :create, :registration_group_id => @registration_group.id
          flash[:error].should == I18n.t('flash.attendee.create.free_not_allowed')
          response.should render_template(:new)
        end
      end

      it "should force registration type to group" do
        RegistrationGroup.any_instance.stubs(:complete).returns(false)
        post :create, :registration_group_id => @registration_group.id, :attendee => {:registration_type_id => RegistrationType.find_by_title('registration_type.free').id}
        assigns(:attendee).registration_type.should == RegistrationType.find_by_title('registration_type.group')
      end
    end
  end
end
