# encoding: UTF-8
require 'spec_helper'

describe Attendance do
  context "associations" do
    it { should belong_to :event }
    it { should belong_to :user }
    it { should belong_to :registration_type }
  end

  context "protect from mass assignment" do
    it { should allow_mass_assignment_of :event_id }
    it { should allow_mass_assignment_of :user_id }
    it { should allow_mass_assignment_of :registration_type_id }
    it { should allow_mass_assignment_of :registration_date }
  end

  context "validations" do
    it { should validate_presence_of :event_id }
    it { should validate_presence_of :user_id }
    it { should validate_presence_of :registration_type_id }
    it { should validate_presence_of :registration_date }
  end

  context "state machine" do
    it "should start pending"
    it "should move to paid upon payment"
    it "should be confirmed on confirmation"
    it "should email upon after confirmed"
    xit "should validate payment agreement when confirmed"
  end

  context "fees" do
    it "should have registration fee according to registration period"
  end

  context "cancelling" do
    it "should be cancelable if pending"
    it "should be cancelable if paid"
    it "should be cancelable if paid"
    it "should be cancelable if confirmed"
    it "should not be cancelable if canceled already"
    it "should not be cancelable few days before the event"
    it "should reimburse part of payment if canceled"
  end
end
