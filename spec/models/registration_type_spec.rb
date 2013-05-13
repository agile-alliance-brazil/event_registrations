# encoding: UTF-8
require 'spec_helper'

describe RegistrationType do  
  context "associations" do
    it { should belong_to :event }
    it { should have_many :registration_prices }
  end
  
  describe "price" do
    it "delegates to RegistrationPeriod" do
      time = Time.now
      type = FactoryGirl.build(:registration_type)
      price = RegistrationPeriod.new

      type.event.registration_periods.expects(:for).with(time).returns([price])
      price.expects(:price_for_registration_type).with(type).returns(599)

      type.price(time).should == 599.00
    end
  end
end
