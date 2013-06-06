# encoding: UTF-8
require 'spec_helper'
require File.join(File.dirname(__FILE__), '../../lib/registration_notifier')

describe RegistrationNotifier do
  before(:each) do
    ::Rails.logger.stubs(:info)
    ::Rails.logger.stubs(:flush)
    Airbrake.stubs(:notify)

    @event = FactoryGirl.build(:event)
    Event.stubs(:find).returns(@event)

    @notifier = RegistrationNotifier.new
  end

  it "should notify attendance created 30 days ago" do
    attendance = FactoryGirl.build(:attendance, event: @event, registration_date: 30.days.ago)
    @event.stubs(:attendances).returns([attendance])

    EmailNotifications.expects(:cancelling_registration).with(attendance).returns(mock(:deliver => true))

    @notifier.cancel
  end

  it "should cancel attendance created 30 days ago" do
    attendance = FactoryGirl.build(:attendance, event: @event, registration_date: 30.days.ago)
    @event.stubs(:attendances).returns([attendance])

    attendance.expects(:cancel)

    @notifier.cancel
  end

  it "should not notify paid attendance" do
    attendance = FactoryGirl.build(:attendance, event: @event, registration_date: 30.days.ago, status: :paid)
    @event.stubs(:attendances).returns([attendance])

    EmailNotifications.expects(:cancelling_registration).never

    @notifier.cancel
  end

  it "should not notify attendance created less than 30 days ago" do
    attendance = FactoryGirl.build(:attendance, event: @event, registration_date: 29.days.ago)
    @event.stubs(:attendances).returns([attendance])

    EmailNotifications.expects(:cancelling_registration).never

    @notifier.cancel
  end
end
