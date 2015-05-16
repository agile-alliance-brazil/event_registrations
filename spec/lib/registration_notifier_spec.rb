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

  describe '#cancel' do
    context 'older than 30 days' do
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

      after { Timecop.return }

      it 'notifies pending attendance older than 30 days ago' do
        EmailNotifications.expects(:cancelling_registration).with(@attendance).returns(mock(deliver_now: true))
        @notifier.cancel
      end

      it 'cancels attendance created 30 days ago' do
        @attendance.expects(:cancel)
        @notifier.cancel
      end
    end

    context 'newer than 30 days' do
      it 'will not notify attendance created less than 30 days ago' do
        Timecop.freeze(Time.zone.now) do
          query_relation = mock
          query_relation.expects(:older_than).with(30.days.ago).returns([])
          @notifier.expects(:pending_attendances).returns(query_relation)
          EmailNotifications.expects(:cancelling_registration).never

          @notifier.cancel
        end
      end
    end

    context 'pending attendances' do
      let(:event) { FactoryGirl.create(:event) }

      it 'having pending and cancelled attendances' do
        cancelled = FactoryGirl.create(:attendance, event: event)
        cancelled.cancel
        pending = FactoryGirl.create(:attendance, event: event)
        paid = FactoryGirl.create(:attendance, event: event)
        paid.pay
        confirmed = FactoryGirl.create(:attendance, event: event)
        confirmed.confirm

        Event.stubs(:find).returns(event)

        expect(@notifier.pending_attendances).to eq([pending])
      end
    end
  end

  describe '#cancel_warning' do
    let(:event) { FactoryGirl.create(:event) }
    after { Timecop.return }

    context 'with one attendance pending 7 days ago' do
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_date: 7.days.ago) }

      it 'calls the method that sends the warning' do
        Event.stubs(:find).returns(event)
        EmailNotifications.expects(:cancelling_registration_warning).once
        @notifier.cancel_warning
      end
    end

    context 'with two attendances 7 days ago, both pending' do
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, status: :pending, registration_date: 7.days.ago) }
      let!(:other_attendance) { FactoryGirl.create(:attendance, event: event, status: :pending, registration_date: 7.days.ago) }

      it 'calls the method that sends the warning' do
        Event.stubs(:find).returns(event)
        EmailNotifications.expects(:cancelling_registration_warning).twice
        @notifier.cancel_warning
      end
    end

    context 'with two attendances 7 days ago, one cancelled and other pending' do
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, status: :pending, registration_date: 7.days.ago) }
      let!(:cancelled_attendance) { FactoryGirl.create(:attendance, event: event, status: :cancelled, registration_date: 7.days.ago) }

      it 'calls the method that sends the warning' do
        Event.stubs(:find).returns(event)
        EmailNotifications.expects(:cancelling_registration_warning).once
        @notifier.cancel_warning
      end
    end

    context 'with two attendances 7 days ago, both paid' do
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, status: :paid, registration_date: 7.days.ago) }
      let!(:other_attendance) { FactoryGirl.create(:attendance, event: event, status: :paid, registration_date: 7.days.ago) }

      it 'not calls the method that sends the warning' do
        Event.stubs(:find).returns(event)
        EmailNotifications.expects(:cancelling_registration_warning).never
        @notifier.cancel_warning
      end
    end

    context 'with two pending attendances, one recent and other from 7 days ago' do
      let!(:attendance) { FactoryGirl.create(:attendance, event: event, status: :paid, registration_date: 6.days.ago) }
      let!(:other_attendance) { FactoryGirl.create(:attendance, event: event, status: :paid, registration_date: 7.days.ago) }

      it 'not calls the method that sends the warning' do
        Event.stubs(:find).returns(event)
        EmailNotifications.expects(:cancelling_registration_warning).never
        @notifier.cancel_warning
      end
    end
  end
end
