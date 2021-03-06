# frozen_string_literal: true

require 'spec_helper'
require File.join(File.dirname(__FILE__), '../../lib/registration_notifier')

describe RegistrationNotifier do
  let(:notifier) { RegistrationNotifier.instance }
  before do
    ::Rails.logger.stubs(:info)
    ::Rails.logger.stubs(:flush)
    Airbrake.stubs(:notify)
  end

  describe '#cancel' do
    context 'when having one active event for today' do
      let!(:event) { FactoryBot.create :event, start_date: 1.month.from_now, end_date: 2.months.from_now }
      context 'and one attendance pending' do
        context 'advised more than 7 days ago' do
          let!(:attendance) { FactoryBot.create(:attendance, event: event, status: :pending, payment_type: :gateway, advised: true, advised_at: 8.days.ago, due_date: 8.days.ago) }
          it 'notifies and cancel the pending attendance' do
            EmailNotifications.expects(:cancelling_registration).once
            notifier.cancel
            expect(Attendance.last.status).to eq 'cancelled'
          end
        end

        context 'advised less than 7 days ago' do
          let!(:attendance) { FactoryBot.create(:attendance, event: event, status: :pending, advised: true, advised_at: 6.days.ago, due_date: 6.days.ago) }
          it 'not send the notification and keep the attendance pending' do
            EmailNotifications.expects(:cancelling_registration).never
            notifier.cancel
            expect(Attendance.last.status).to eq 'pending'
          end
        end
      end

      context 'not advised' do
        let!(:attendance) { FactoryBot.create(:attendance, event: event, status: :pending, advised: false) }
        it 'not send the notification and keep the attendance pending' do
          EmailNotifications.expects(:cancelling_registration).never
          notifier.cancel
          expect(Attendance.last.status).to eq 'pending'
        end
      end

      context 'and one attendance accepted and advised 7 days ago with gateway as payment type' do
        let!(:attendance) { FactoryBot.create(:attendance, event: event, status: :accepted, payment_type: :gateway, advised: true, advised_at: 7.days.ago, due_date: 7.days.ago) }
        it 'notifies the accepted attendance about the cancellation and cancel the registration' do
          EmailNotifications.expects(:cancelling_registration).once
          notifier.cancel
          expect(Attendance.last.status).to eq 'cancelled'
        end
      end

      context 'and one attendance from 10 days ago not advised' do
        let!(:attendance) { FactoryBot.create(:attendance, event: event, payment_type: :gateway, advised_at: 10.days.ago, advised: false) }
        it 'notifies the pending attendance' do
          EmailNotifications.expects(:cancelling_registration).never
          notifier.cancel
        end
      end

      context 'and one attendance older than 15 days with bank_deposit as payment type' do
        let!(:attendance) { FactoryBot.create(:attendance, event: event, payment_type: :bank_deposit, advised_at: 15.days.ago, advised: true) }
        it 'notifies the pending attendance' do
          EmailNotifications.expects(:cancelling_registration).never
          notifier.cancel
        end
      end

      context 'and one attendance older than 15 days with statement of agreement as payment type' do
        let!(:attendance) { FactoryBot.create(:attendance, event: event, payment_type: :statement_agreement, advised_at: 15.days.ago, advised: true) }
        it 'notifies the pending attendance' do
          EmailNotifications.expects(:cancelling_registration).never
          notifier.cancel
        end
      end

      context 'and with an event already started' do
        let!(:event) { FactoryBot.create :event, start_date: 2.days.ago, end_date: 2.months.from_now }
        let!(:attendance) { FactoryBot.create(:attendance, event: event, payment_type: :gateway, advised_at: 15.days.ago, advised: true) }
        it 'notifies the pending attendance' do
          EmailNotifications.expects(:cancelling_registration).never
          notifier.cancel
        end
      end
    end
  end

  describe '#cancel_warning' do
    context 'when having one active event for today' do
      let!(:event) { FactoryBot.create :event, start_date: 1.month.from_now, end_date: 2.months.from_now, days_to_charge: 7 }
      context 'and one attendance older than 7 days' do
        context 'with gateway as payment type' do
          context 'and not advised' do
            let!(:attendance) { FactoryBot.create(:attendance, status: :pending, event: event, payment_type: :gateway, last_status_change_date: 7.days.ago, advised: false) }
            it 'notifies the pending attendance and mark as advised' do
              EmailNotifications.expects(:cancelling_registration_warning).once
              notifier.cancel_warning
              expect(Attendance.last.advised).to be true
              expect(Attendance.last.advised_at).to be_within(30.seconds).of Time.zone.now
            end
          end
          context 'and has been already advised' do
            let!(:attendance) { FactoryBot.create(:attendance, event: event, payment_type: :gateway, last_status_change_date: 7.days.ago, advised: true, advised_at: Time.zone.today) }
            it 'notifies the pending attendance and mark as advised' do
              EmailNotifications.expects(:cancelling_registration_warning).never
              notifier.cancel_warning
            end
          end
        end
      end

      context 'and one accepted attendance older than 14 days with gateway as payment type' do
        let!(:attendance) { FactoryBot.create(:attendance, event: event, payment_type: :gateway, last_status_change_date: 7.days.ago, status: :accepted) }
        it 'notifies the accepted attendance' do
          EmailNotifications.expects(:cancelling_registration_warning).once
          notifier.cancel_warning
        end
      end

      context 'and one attendance older than 13 days with gateway as payment type' do
        let!(:attendance) { FactoryBot.create(:attendance, event: event, payment_type: :gateway, last_status_change_date: 6.days.ago) }
        it 'notifies the pending attendance' do
          EmailNotifications.expects(:cancelling_registration_warning).never
          notifier.cancel_warning
        end
      end

      context 'and one attendance older than 15 days with bank_deposit as payment type' do
        let!(:attendance) { FactoryBot.create(:attendance, event: event, payment_type: :bank_deposit, last_status_change_date: 7.days.ago) }
        it 'notifies the pending attendance' do
          EmailNotifications.expects(:cancelling_registration_warning).never
          notifier.cancel_warning
        end
      end

      context 'and one attendance older than 15 days with statement of agreement as payment type' do
        let!(:attendance) { FactoryBot.create(:attendance, event: event, payment_type: :statement_agreement, last_status_change_date: 8.days.ago) }
        it 'notifies the pending attendance' do
          EmailNotifications.expects(:cancelling_registration_warning).never
          notifier.cancel_warning
        end
      end
    end
  end
end
