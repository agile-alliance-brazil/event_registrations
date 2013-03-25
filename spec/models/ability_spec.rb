# encoding: UTF-8
require 'spec_helper'

describe Ability do
  before(:each) do
    @user = FactoryGirl.build(:user)
    @event = FactoryGirl.build(:event)
  end
  
  shared_examples_for "all users" do
    it "can read public entities" do
      @ability.should be_able_to(:read, 'static_pages')
      @ability.should be_able_to(:manage, 'password_resets')
      @ability.should be_able_to(:read, Event)
      @ability.should be_able_to(:index, Event)
    end
  end

  context "- all users (guests)" do
    before(:each) do
      @ability = Ability.new(@user, @event)
    end

    it_should_behave_like "all users"

    it "can manage their users" do
      @ability.should be_able_to(:manage, @user)
    end

    it "can view their attendances" do
      attendance = FactoryGirl.build(:attendance)
      @ability.should_not be_able_to(:show, attendance)
      attendance.user = @user
      @ability.should be_able_to(:show, attendance)
    end

    it "cannot index all attendances" do
      @ability.should_not be_able_to(:index, Attendance)
    end
    
    describe "can create a new attendance if:" do
      before(:each) do
        Time.zone.stubs(:now).returns(Ability::REGISTRATION_DEADLINE - 3.days)
      end
      
      it "- before deadline" do
        Time.zone.expects(:now).returns(Ability::REGISTRATION_DEADLINE)
        @ability.should be_able_to(:create, Attendance)
      end
      
      it "- after deadline can't register" do
        Time.zone.expects(:now).returns(Ability::REGISTRATION_DEADLINE + 1.second)
        @ability.should_not be_able_to(:create, Attendance)
      end
    end
  end
  
  context "- admin" do
    before(:each) do
      @user.add_role "admin"
      @ability = Ability.new(@user, @event)
    end

    it "can manage all" do
      @ability.should be_able_to(:manage, :all)
    end
  end

  context "- organizer" do
    before(:each) do
      @user.add_role "organizer"
      @ability = Ability.new(@user, @event)
    end

    it_should_behave_like "all users"
  
    it "can show attendances" do
      @ability.should be_able_to(:show, Attendance)
    end
    
    it "can update attendances" do
      @ability.should be_able_to(:update, Attendance)
    end

    it "can index all attendances" do
      @ability.should be_able_to(:index, Attendance)
    end
    
    describe "can create a new attendance if:" do
      it "- before deadline" do
        Time.zone.stubs(:now).returns(Ability::REGISTRATION_DEADLINE)
        @ability.should be_able_to(:create, Attendance)
      end
      
      it "- after deadline" do
        Time.zone.stubs(:now).returns(Ability::REGISTRATION_DEADLINE + 1.second)
        @ability.should be_able_to(:create, Attendance)
      end
    end
  end
end
