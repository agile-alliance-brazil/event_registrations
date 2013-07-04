# encoding: UTF-8
require 'spec_helper'

describe Ability do
  before(:each) do
    @user = FactoryGirl.build(:user)
    @event = FactoryGirl.build(:event)
    @deadline = @event.registration_periods.last.end_at
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

    it "can cancel (destroy) their attendances" do
      attendance = FactoryGirl.build(:attendance)
      @ability.should_not be_able_to(:destroy, attendance)
      attendance.user = @user
      @ability.should be_able_to(:destroy, attendance)
    end

    it "cannot confirm their attendances" do
      attendance = FactoryGirl.build(:attendance, user: @user)
      @ability.should_not be_able_to(:confirm, attendance)
    end

    it "cannot index all attendances" do
      @ability.should_not be_able_to(:index, Attendance)
    end

    describe "can create a new attendance if:" do
      it "- before deadline" do
        Timecop.freeze(@deadline - 1.day) do
          @ability.should be_able_to(:create, Attendance)
        end
      end

      it "- after deadline can't register" do
        Timecop.freeze(@deadline + 1.second) do
          @ability.should_not be_able_to(:create, Attendance)
        end
      end
    end

    it "can enable voting if when user match" do
      attendance = FactoryGirl.build(:attendance)
      @ability.should_not be_able_to(:enable_voting, attendance)
      attendance.user = @user
      @ability.should be_able_to(:enable_voting, attendance)
    end

    it "can read voting instructions when user match" do
      attendance = FactoryGirl.build(:attendance)
      @ability.should_not be_able_to(:voting_instructions, attendance)
      attendance.user = @user
      @ability.should be_able_to(:voting_instructions, attendance)
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

    it "can cancel (destroy) attendances" do
      @ability.should be_able_to(:destroy, Attendance)
    end

    it "can confirm attendances" do
      @ability.should be_able_to(:confirm, Attendance)
    end

    it "can update attendances" do
      @ability.should be_able_to(:update, Attendance)
    end

    it "can index all attendances" do
      @ability.should be_able_to(:index, Attendance)
    end

    it "can create transfer" do
      @ability.should be_able_to(:create, "transfers")
    end

    describe "can create a new attendance if:" do
      it "- before deadline" do
        Timecop.freeze(@deadline - 1.day) do
          @ability.should be_able_to(:create, Attendance)
        end
      end

      it "- after deadline" do
        Timecop.freeze(@deadline + 1.second) do
          @ability.should be_able_to(:create, Attendance)
        end
      end
    end
  end
end
