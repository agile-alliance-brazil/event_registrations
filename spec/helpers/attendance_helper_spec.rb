# encoding: UTF-8
require 'spec_helper'

describe AttendanceHelper do
  describe "label_for attendance and registration type" do
    before do
      @attendance = FactoryGirl.build(:attendance, registration_date: Time.zone.local(2013, 03, 21))
      @individual = RegistrationType.find_by_title('registration_type.individual')
    end
    it "should show title and price" do
      attendance_price(@attendance, @individual).should == 250
    end

    it "should show price according to attendance (not registration type directly)" do
      @attendance.event.attendances.expects(:count).returns(150)

      attendance_price(@attendance, @individual).should == 399
    end
  end
end