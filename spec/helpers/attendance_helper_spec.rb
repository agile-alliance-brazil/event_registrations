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

  describe "attendance_prices as a map" do
    it "should return attendance prices with ids as keys and formatted prices as values" do
      attendance = FactoryGirl.build(:attendance, registration_date: Time.zone.local(2013, 03, 21))
      other = attendance.event.registration_types.build
      individual = attendance.event.registration_types.first
      attendance.expects(:registration_fee).with(individual).returns(250)
      attendance.expects(:registration_fee).with(other).returns(400)

      attendance_prices(attendance).should == {individual.id => "R$ 250,00", other.id => "R$ 400,00"}
    end
  end

  describe "price_table_link" do
    it "should show pure link if no locale information in the link" do
      event = FactoryGirl.build(:event)
      price_table_link(event, :pt).should == event.price_table_link
      price_table_link(event, :en).should == event.price_table_link
    end

    it "should replace :locale placeholder in the link if present" do
      event = FactoryGirl.build(:event, price_table_link: 'http://localhost:9292/testing/:locale/works')
      price_table_link(event, :pt).should == 'http://localhost:9292/testing/pt/works'
      price_table_link(event, :en).should == 'http://localhost:9292/testing/en/works'
    end

    it "should works as a query param as well" do
      event = FactoryGirl.build(:event, price_table_link: 'http://localhost:9292/testing?locale=:locale')
      price_table_link(event, :pt).should == 'http://localhost:9292/testing?locale=pt'
      price_table_link(event, :en).should == 'http://localhost:9292/testing?locale=en'
    end
  end
end