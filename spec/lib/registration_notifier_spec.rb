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

  context "cancel" do
    context "older than 30 days" do
      before do
        Timecop.freeze(Time.zone.now)
        deadline = 30.days.ago
        @attendance = FactoryGirl.build(
          :attendance,
          event: @event,
          registration_date: deadline
        )

        query_relation = mock
        query_relation.expects(:older_than).with(deadline).returns([@attendance])
        @notifier.expects(:pending_attendances).returns(query_relation)
      end

      after do
        Timecop.return
      end

      it "should notify pending attendance older than 30 days ago" do
        EmailNotifications.expects(:cancelling_registration)
          .with(@attendance).returns(mock(deliver_now: true))

        @notifier.cancel
      end

      it "should cancel attendance created 30 days ago" do
        @attendance.expects(:cancel)

        @notifier.cancel
      end
    end

    context "newer than 30 days" do
      it "should not notify attendance created less than 30 days ago" do
        Timecop.freeze(Time.zone.now) do
          query_relation = mock
          query_relation.expects(:older_than).with(30.days.ago).returns([])
          @notifier.expects(:pending_attendances).returns(query_relation)
          EmailNotifications.expects(:cancelling_registration).never

          @notifier.cancel
        end
      end
    end

    context "pending attendances" do
      it "should have pending attendances without manual registrations" do
        event = FactoryGirl.create(:event)
        manual_type = FactoryGirl.create(:registration_type, title: 'registration_type.manual.title', event: event)

        cancelled = FactoryGirl.create(:attendance, event: event)
        cancelled.cancel
        pending = FactoryGirl.create(:attendance, event: event)
        paid = FactoryGirl.create(:attendance, event: event)
        paid.pay
        confirmed = FactoryGirl.create(:attendance, event: event)
        confirmed.confirm

        manual = FactoryGirl.create(:attendance, event: event, registration_type: manual_type)

        Event.stubs(:find).returns(event)

        expect(@notifier.pending_attendances).to eq([pending])
      end
    end
  end
end
