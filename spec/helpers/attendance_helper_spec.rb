# encoding: UTF-8
require 'spec_helper'

describe AttendanceHelper do
  describe "attendance_price for attendance and registration type" do
    it "should return attendance price" do
      attendance = FactoryGirl.build(:attendance, registration_date: Time.zone.local(2013, 03, 21))
      individual = attendance.event.registration_types.first
      attendance.expects(:registration_fee).with(individual).returns(250)

      attendance_price(attendance, individual).should == 250
    end
  end
end