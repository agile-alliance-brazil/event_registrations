# encoding: UTF-8
require 'spec_helper'

describe RegistrationPeriod do  
  before do
    @event = FactoryGirl.create(:event)
    @regular = @event.registration_periods.first 
    @super_early_bird = FactoryGirl.create(:registration_period, event: @event, title: 'registration_period.super_early_bird', start_at: Time.zone.local(2013, 01, 01), end_at: Time.zone.local(2013, 01, 31).end_of_day)
    @early_bird = FactoryGirl.create(:registration_period, event: @event, title: 'registration_period.early_bird', start_at: Time.zone.local(2013, 02, 01), end_at: Time.zone.local(2013, 02, 28).end_of_day)
    @regular.tap{|p| p.start_at = Time.zone.local(2013, 03, 01); p.end_at = Time.zone.local(2013, 03, 31).end_of_day}.save
    @late = FactoryGirl.create(:registration_period, event: @event, title: 'registration_period.late', start_at: Time.zone.local(2013, 04, 01), end_at: Time.zone.local(2013, 04, 30).end_of_day)
    @last_minute = FactoryGirl.create(:registration_period, event: @event, title: 'registration_period.last_minute', start_at: Time.zone.local(2013, 05, 01), end_at: Time.zone.local(3013, 05, 31).end_of_day)
  end

  context "prices" do
    it "should be super_early_bird if title matches" do
      @super_early_bird.should be_super_early_bird
      @early_bird.should_not be_super_early_bird
      @regular.should_not be_super_early_bird
      @late.should_not be_super_early_bird
      @last_minute.should_not be_super_early_bird
    end
    
    context "for registration types" do
      before do
        @individual = @event.registration_types.first
      end

      it "should delegate to RegistrationPrice" do
        price = RegistrationPrice.new
        price.value = 250
        RegistrationPrice.stubs(:for).with(@super_early_bird, @individual).returns([price])
        @super_early_bird.price_for_registration_type(@individual).should == 250.00
      end

      it "should throw an InvalidPrice error if no registration price can be found" do
        RegistrationPrice.stubs(:for).with(@super_early_bird, @individual).returns([])
        lambda { @super_early_bird.price_for_registration_type(@individual) }.should raise_error(InvalidPrice)
      end
    end
  end
  
  context "appropriate period" do    
    it "should not include date before its start" do
      RegistrationPeriod.for(@regular.start_at - 1.second).first.should == @early_bird
    end

    it "should include its start date" do
      RegistrationPeriod.for(@regular.start_at).first.should == @regular
    end
    
    it "should include a date between start and end" do
      RegistrationPeriod.for(@regular.start_at + 5).first.should == @regular
    end
    
    it "should include end date" do
      RegistrationPeriod.for(@regular.end_at).first.should == @regular
    end
    
    it "should not include date after end date" do
      RegistrationPeriod.for(@regular.end_at + 1.week).first.should == @late
    end
    
    # TODO Crappy test depends on other events not starting before this.
    it "should not have any period before super_early_bird" do
      RegistrationPeriod.for(@super_early_bird.start_at - 1.second).first.should be_nil
    end
    
    # TODO Crappy test depends on other events not finishing after this.
    it "should not have any period after last minute" do
      RegistrationPeriod.for(@last_minute.end_at + 1.second).first.should be_nil
    end
  end
end
