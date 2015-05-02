# encoding: UTF-8
require 'spec_helper'

describe AttendanceHelper, type: :helper do
  describe '#attendance_price' do
    it 'returns attendance price' do
      attendance = FactoryGirl.build(:attendance, registration_value: 250)
      expect(attendance_price(attendance)).to eq 250
    end
  end

  describe '#price_table_link' do
    it 'show pure link if no locale information in the link' do
      event = FactoryGirl.build(:event)
      expect(price_table_link(event, :pt)).to eq(event.price_table_link)
      expect(price_table_link(event, :en)).to eq(event.price_table_link)
    end

    it 'replaces :locale placeholder in the link if present' do
      event = FactoryGirl.build(:event, price_table_link: 'http://localhost:9292/testing/:locale/works')
      expect(price_table_link(event, :pt)).to eq('http://localhost:9292/testing/pt/works')
      expect(price_table_link(event, :en)).to eq('http://localhost:9292/testing/en/works')
    end

    it 'works as a query param as well' do
      event = FactoryGirl.build(:event, price_table_link: 'http://localhost:9292/testing?locale=:locale')
      expect(price_table_link(event, :pt)).to eq('http://localhost:9292/testing?locale=pt')
      expect(price_table_link(event, :en)).to eq('http://localhost:9292/testing?locale=en')
    end

    pending 'Test if event has no price_table_link defined. The field on model is not required.'
  end

  describe '#convert_registration_types_to_radio' do
    before { @attendance = FactoryGirl.build(:attendance, registration_date: Time.zone.local(2013, 03, 21)) }

    it 'returns empty array for empty registration types' do
      expect(convert_registration_types_to_radio(@attendance, [])).to eq([])
    end

    it 'returns array with label and value for one registration type' do
      individual = @attendance.event.registration_types.first
      @attendance.expects(:registration_value).returns(250)

      radio_collection = convert_registration_types_to_radio(@attendance, [individual])
      expect(radio_collection).to eq([["#{t(individual.title)} - R$ 250,00", individual.id]])
    end
  end
end