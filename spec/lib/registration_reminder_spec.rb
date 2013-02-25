# encoding: UTF-8
require 'spec_helper'
require File.join(Rails.root, '/lib/registration_reminder.rb')

describe RegistrationReminder do
  before(:each) do
    EmailNotifications.stubs(:registration_reminder).returns(stub(:deliver => true))
    Rails.logger.stubs(:info)
    Rails.logger.stubs(:flush)
    Airbrake.stubs(:notify)
    
    @event = FactoryGirl.create(:event)
    Event.stubs(:current).returns(@event)
    
    @reminder = RegistrationReminder.new
  end
    
  describe "#publish" do
    before(:each) do
      @attendances = [FactoryGirl.create(:attendance), FactoryGirl.create(:attendance, :user => FactoryGirl.create(:user, :cpf => '366.624.533-15'))]
      Attendance.stubs(:all).returns(@attendances)
    end
  
    it "should send reminder e-mails" do
      Attendance.expects(:all).with(
        :conditions => ['event_id = ? AND status = ? AND registration_type_id <> ? AND registration_date < ?', @event.id, 'pending', 2, Time.zone.local(2011, 5, 21)], :order => 'id').returns(@attendances)
      EmailNotifications.expects(:registration_reminder).with(@attendances[0]).with(@attendances[1]).returns(stub(:deliver => true))
    
      @reminder.publish
    end

    it "should log reminder e-mails sent" do
      Rails.logger.expects(:info).with("[ATTENDANCE] #{@attendances[0].to_param}")
      Rails.logger.expects(:info).with("[ATTENDANCE] #{@attendances[1].to_param}")
      Rails.logger.expects(:info).times(2).with("  [REMINDER] OK")
      
      @reminder.publish
    end

    it "should capture error when sending reminder and move on" do
      error = StandardError.new('error')
      EmailNotifications.expects(:registration_reminder).with(@attendances[0]).raises(error)
      EmailNotifications.expects(:registration_reminder).with(@attendances[1]).returns(stub(:deliver => true))
      
      Rails.logger.expects(:info).with("  [FAILED REMINDER] error")
      Rails.logger.expects(:info).with("  [REMINDER] OK")
      Airbrake.expects(:notify).with(error)
      
      @reminder.publish
    end

    it "should flush log at the end" do
      Rails.logger.expects(:flush)
      
      @reminder.publish
    end
  end
end
