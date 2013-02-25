# encoding: UTF-8
require 'spec_helper'

describe RegistrationType do  
  context "associations" do
    it { should belong_to :event }
    it { should have_many :registration_prices }
  end
  
  describe "price" do
    it "delegates to RegistrationPeriod" do
      type = RegistrationType.find_by_title('registration_type.individual')
      late = RegistrationPeriod.find_by_title('registration_period.late')
      type.price(late.start_at + 1.day).should == 599.00
    end
  end
end
