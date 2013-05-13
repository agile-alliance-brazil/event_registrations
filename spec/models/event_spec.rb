# encoding: UTF-8
require 'spec_helper'

describe Event do
  context "associations" do
    it { should have_many :attendances }
    it { should have_many :registration_periods }
    it { should have_many :registration_types }
  end

  context "attendance limit" do
    before do
      @event = FactoryGirl.build(:event)
      @event.attendance_limit = 1
    end
    it "should be able to add more attendance without limit" do
      @event.attendance_limit = nil

      @event.can_add_attendance?.should be_true
    end
    it "should be able to add more attendance with 0 limit" do
      @event.attendance_limit = 0

      @event.can_add_attendance?.should be_true
    end
    it "should be able to add more attendance before limit" do
      @event.can_add_attendance?.should be_true
    end
    it "should not be able to add more attendance after reaching limit" do
      @event.attendances << FactoryGirl.build(:attendance, :event => @event)

      @event.can_add_attendance?.should be_false
    end
  end
end