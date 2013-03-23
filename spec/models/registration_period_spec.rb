# encoding: UTF-8
require 'spec_helper'

describe RegistrationPeriod do  
  context "prices" do
    before do
      @super_early_bird = RegistrationPeriod.find_by_title('registration_period.super_early_bird')
      @early_bird = RegistrationPeriod.find_by_title('registration_period.early_bird')
      @regular = RegistrationPeriod.find_by_title('registration_period.regular')
      @late = RegistrationPeriod.find_by_title('registration_period.late')
      @last_minute = RegistrationPeriod.find_by_title('registration_period.last_minute')
    end

    it "should be super_early_bird if title matches" do
      @super_early_bird.should be_super_early_bird
      @early_bird.should_not be_super_early_bird
      @regular.should_not be_super_early_bird
      @late.should_not be_super_early_bird
      @last_minute.should_not be_super_early_bird
    end
    
    context "for registration types" do
      before do
        @individual = RegistrationType.find_by_title('registration_type.individual')
        @group = RegistrationType.find_by_title('registration_type.group')
        @free = RegistrationType.find_by_title('registration_type.free')
      end
    
      it "super_early_bird" do
        @super_early_bird.price_for_registration_type(@individual).should == 250.00
        @super_early_bird.price_for_registration_type(@group).should == 250.00
        @super_early_bird.price_for_registration_type(@free).should == 0.00
        lambda { @super_early_bird.price_for_registration_type(nil) }.should raise_error(InvalidPrice)
      end

      it "early_bird" do
        @early_bird.price_for_registration_type(@individual).should == 399.00
        @early_bird.price_for_registration_type(@group).should == 399.00
        @early_bird.price_for_registration_type(@free).should == 0.00
        lambda { @early_bird.price_for_registration_type(nil) }.should raise_error(InvalidPrice)
      end

      it "regular" do
        @regular.price_for_registration_type(@individual).should == 499.00
        @regular.price_for_registration_type(@group).should == 499.00
        @regular.price_for_registration_type(@free).should == 0.00
        lambda { @regular.price_for_registration_type(nil) }.should raise_error(InvalidPrice)
      end

      it "late" do
        @late.price_for_registration_type(@individual).should == 599.00
        @late.price_for_registration_type(@group).should == 599.00
        @late.price_for_registration_type(@free).should == 0.00
        lambda { @late.price_for_registration_type(nil) }.should raise_error(InvalidPrice)
      end

      it "last minute" do
        @last_minute.price_for_registration_type(@individual).should == 799.00
        @last_minute.price_for_registration_type(@group).should == 799.00
        @last_minute.price_for_registration_type(@free).should == 0.00
        lambda { @last_minute.price_for_registration_type(nil) }.should raise_error(InvalidPrice)
      end
    end

    context "super_early_bird prices by registration limits" do
      before do
        @type = RegistrationType.find_by_title('registration_type.individual')
        @super_early = RegistrationPeriod.find_by_title('registration_period.super_early_bird')
      end

      it "should be 250 for 149 attendances (pending, paid or confirmed)" do
        Attendance.expects(:find_all_by_event_id)
                  .with(@super_early.event_id)
                  .returns([1] * 149)

        @super_early.price_for_registration_type(@type).should == 250
      end
      
      it "should be 399 after 150 attendances" do
        Attendance.expects(:find_all_by_event_id)
                  .with(@super_early.event_id)
                  .returns([1] * 150)

        @super_early.price_for_registration_type(@type).should == 399
      end
    end
  end
  
  context "appropriate period" do
    before :each do
      @period = RegistrationPeriod.find_by_title('registration_period.regular')
    end
    
    it "should not include date before its start" do
      RegistrationPeriod.for(@period.start_at - 1.second).first.should == RegistrationPeriod.find_by_title('registration_period.early_bird')
    end

    it "should include its start date" do
      RegistrationPeriod.for(@period.start_at).first.should == @period
    end
    
    it "should include a date between start and end" do
      RegistrationPeriod.for(@period.start_at + 5).first.should == @period
    end
    
    it "should include end date" do
      RegistrationPeriod.for(@period.end_at).first.should == @period
    end
    
    it "should not include date after end date" do
      RegistrationPeriod.for(@period.end_at + 1.week).first.should == RegistrationPeriod.find_by_title('registration_period.late')
    end
    
    it "should not have any period before super_early_bird" do
      super_early = RegistrationPeriod.find_by_title('registration_period.super_early_bird')
      RegistrationPeriod.for(super_early.start_at - 1.second).first.should be_nil
    end
    
    it "should not have any period after last minute" do
      last_minute = RegistrationPeriod.find_by_title('registration_period.last_minute')
      RegistrationPeriod.for(last_minute.end_at + 1.second).first.should be_nil
    end
  end
end
