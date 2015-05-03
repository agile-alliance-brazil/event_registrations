# encoding: UTF-8
require 'spec_helper'

describe Ability, type: :model do
  before(:each) do
    @user = FactoryGirl.build(:user)
    @event = FactoryGirl.build(:event)
    @deadline = @event.end_date
  end
  
  shared_examples_for "all users" do
    it "can read public entities" do
      expect(@ability).to be_able_to(:read, 'static_pages')
      expect(@ability).to be_able_to(:manage, 'password_resets')
      expect(@ability).to be_able_to(:read, Event)
      expect(@ability).to be_able_to(:index, Event)
    end
  end

  context "- all users (guests)" do
    before(:each) do
      @ability = Ability.new(@user, @event)
    end

    it_should_behave_like "all users"

    it "can manage their users" do
      expect(@ability).to be_able_to(:manage, @user)
    end

    it "can view their attendances" do
      attendance = FactoryGirl.build(:attendance)
      expect(@ability).not_to be_able_to(:show, attendance)
      attendance.user = @user
      expect(@ability).to be_able_to(:show, attendance)
    end

    it "can cancel (destroy) their attendances" do
      attendance = FactoryGirl.build(:attendance)
      expect(@ability).not_to be_able_to(:destroy, attendance)
      attendance.user = @user
      expect(@ability).to be_able_to(:destroy, attendance)
    end

    it "cannot confirm their attendances" do
      attendance = FactoryGirl.build(:attendance, user: @user)
      expect(@ability).not_to be_able_to(:confirm, attendance)
    end

    it "cannot index all attendances" do
      expect(@ability).not_to be_able_to(:index, Attendance)
    end

    describe "can create a new attendance if:" do
      it "- before deadline" do
        Timecop.freeze(@deadline - 1.day) do
          expect(@ability).to be_able_to(:create, Attendance)
        end
      end

      it "- after deadline can't register" do
        Timecop.freeze(@deadline + 1.second) do
          expect(@ability).not_to be_able_to(:create, Attendance)
        end
      end
    end

    it "can enable voting if when user match" do
      attendance = FactoryGirl.build(:attendance)
      expect(@ability).not_to be_able_to(:enable_voting, attendance)
      attendance.user = @user
      expect(@ability).to be_able_to(:enable_voting, attendance)
    end

    it "can read voting instructions when user match" do
      attendance = FactoryGirl.build(:attendance)
      expect(@ability).not_to be_able_to(:voting_instructions, attendance)
      attendance.user = @user
      expect(@ability).to be_able_to(:voting_instructions, attendance)
    end
  end

  context "- admin" do
    before(:each) do
      @user.add_role "admin"
      @ability = Ability.new(@user, @event)
    end

    it "can manage all" do
      expect(@ability).to be_able_to(:manage, :all)
    end
  end

  context "- organizer" do
    before(:each) do
      @user.add_role "organizer"
      @ability = Ability.new(@user, @event)
    end

    it_should_behave_like "all users"

    it "can show attendances" do
      expect(@ability).to be_able_to(:show, Attendance)
    end

    it "can cancel (destroy) attendances" do
      expect(@ability).to be_able_to(:destroy, Attendance)
    end

    it "can confirm attendances" do
      expect(@ability).to be_able_to(:confirm, Attendance)
    end

    it "can update attendances" do
      expect(@ability).to be_able_to(:update, Attendance)
    end

    it "can index all attendances" do
      expect(@ability).to be_able_to(:index, Attendance)
    end

    it "can create transfer" do
      expect(@ability).to be_able_to(:create, "transfers")
    end

    describe "can create a new attendance if:" do
      it "- before deadline" do
        Timecop.freeze(@deadline - 1.day) do
          expect(@ability).to be_able_to(:create, Attendance)
        end
      end

      it "- after deadline" do
        Timecop.freeze(@deadline + 1.second) do
          expect(@ability).to be_able_to(:create, Attendance)
        end
      end
    end
  end
end
