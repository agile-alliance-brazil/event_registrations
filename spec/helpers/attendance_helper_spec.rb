# encoding: UTF-8
require 'spec_helper'

describe AttendanceHelper, type: :helper do
  describe "attendance_price for attendance and registration type" do
    it "should return attendance price" do
      attendance = FactoryGirl.build(:attendance, registration_date: Time.zone.local(2013, 03, 21))
      individual = attendance.event.registration_types.first
      attendance.expects(:registration_fee).with(individual).returns(250)

      expect(attendance_price(attendance, individual)).to eq(250)
    end
  end

  describe "attendance_prices as a map" do
    it "should return attendance prices with ids as keys and formatted prices as values" do
      attendance = FactoryGirl.build(:attendance, registration_date: Time.zone.local(2013, 03, 21))
      other = attendance.event.registration_types.build
      individual = attendance.event.registration_types.first
      attendance.expects(:registration_fee).with(individual).returns(250)
      attendance.expects(:registration_fee).with(other).returns(400)

      expect(attendance_prices(attendance)).to eq({individual.id => "R$ 250,00", other.id => "R$ 400,00"})
    end
  end

  describe "price_table_link" do
    it "should show pure link if no locale information in the link" do
      event = FactoryGirl.build(:event)
      expect(price_table_link(event, :pt)).to eq(event.price_table_link)
      expect(price_table_link(event, :en)).to eq(event.price_table_link)
    end

    it "should replace :locale placeholder in the link if present" do
      event = FactoryGirl.build(:event, price_table_link: 'http://localhost:9292/testing/:locale/works')
      expect(price_table_link(event, :pt)).to eq('http://localhost:9292/testing/pt/works')
      expect(price_table_link(event, :en)).to eq('http://localhost:9292/testing/en/works')
    end

    it "should works as a query param as well" do
      event = FactoryGirl.build(:event, price_table_link: 'http://localhost:9292/testing?locale=:locale')
      expect(price_table_link(event, :pt)).to eq('http://localhost:9292/testing?locale=pt')
      expect(price_table_link(event, :en)).to eq('http://localhost:9292/testing?locale=en')
    end

    pending 'Test if event has no price_table_link defined. The field on model is not required.'
  end

  describe "convert_registration_types_to_radio for attendance and registration types" do
    before do
      @attendance = FactoryGirl.build(:attendance, registration_date: Time.zone.local(2013, 03, 21))
    end

    it "should return empty array for empty registration types" do
      expect(convert_registration_types_to_radio(@attendance, [])).to eq([])
    end

    it "should return array with label and value for one registration type" do
      individual = @attendance.event.registration_types.first
      @attendance.expects(:registration_fee).with(individual).returns(250)

      radio_collection = convert_registration_types_to_radio(@attendance, [individual])
      expect(radio_collection).to eq([["#{t(individual.title)} - R$ 250,00", individual.id]])
    end

    it "should return array with label and value for multiple registration types" do
      individual = @attendance.event.registration_types.first
      other = @attendance.event.registration_types.build
      @attendance.expects(:registration_fee).with(individual).returns(250)
      @attendance.expects(:registration_fee).with(other).returns(400)

      radio_collection = convert_registration_types_to_radio(@attendance, [individual, other])
      expect(radio_collection).to eq([
        ["#{t(individual.title)} - R$ 250,00", individual.id],
        ["#{t(other.title)} - R$ 400,00", other.id],
      ])
    end
  end
end