require 'spec_helper'
require File.join(File.dirname(__FILE__), '../../lib/registration_confirming')

describe RegistrationConfirming do
  let(:confirming) { RegistrationConfirming.new }

  before do
    ::Rails.logger.stubs(:info)
    ::Rails.logger.stubs(:flush)
    Airbrake.stubs(:notify)
  end

  describe '#confirming' do
    context 'past event' do
      let(:past_event) { FactoryGirl.create(:event, start_date: 7.days.ago, end_date: 6.days.ago) }
      context 'two attendances' do
        context 'and both are paid' do
          let!(:attendance) { FactoryGirl.create(:attendance, event: past_event, status: :paid) }
          let!(:other_attendance) { FactoryGirl.create(:attendance, event: past_event, status: :paid) }
          it 'ignores the attendances' do
            EmailNotifications.expects(:registration_confirmed).never
            confirming.confirm
            expect(attendance.reload.status).to eq 'paid'
            expect(other_attendance.reload.status).to eq 'paid'
          end
        end
      end
    end

    context 'current event' do
      let(:event) { FactoryGirl.create :event }
      context 'when individual' do
        let!(:out) { FactoryGirl.create(:attendance, event: event, status: :cancelled) }
        context 'two attendances' do
          context 'and both are paid' do
            let!(:attendance) { FactoryGirl.create(:attendance, event: event, status: :paid) }
            let!(:other_attendance) { FactoryGirl.create(:attendance, event: event, status: :paid) }
            it 'confirms the attendance and sends the confirmation email' do
              EmailNotifications.expects(:registration_confirmed).twice
              confirming.confirm
              expect(attendance.reload.status).to eq 'confirmed'
              expect(other_attendance.reload.status).to eq 'confirmed'
            end
          end

          context 'and one is pending and other is paid' do
            let!(:attendance) { FactoryGirl.create(:attendance, event: event, status: :pending) }
            let!(:other_attendance) { FactoryGirl.create(:attendance, event: event, status: :paid) }
            it 'keeps the attendance pending' do
              EmailNotifications.expects(:registration_confirmed).once
              confirming.confirm
              expect(attendance.reload.status).to eq 'pending'
              expect(other_attendance.reload.status).to eq 'confirmed'
            end
          end

          context 'and one is accepted and other is paid' do
            let!(:attendance) { FactoryGirl.create(:attendance, event: event, status: :accepted) }
            let!(:other_attendance) { FactoryGirl.create(:attendance, event: event, status: :paid) }
            it 'keeps the attendance accepted' do
              EmailNotifications.expects(:registration_confirmed).once
              confirming.confirm
              expect(attendance.reload.status).to eq 'accepted'
              expect(other_attendance.reload.status).to eq 'confirmed'
            end
          end

          context 'and one is confirmed and other is paid' do
            let!(:attendance) { FactoryGirl.create(:attendance, event: event, status: :confirmed) }
            let!(:other_attendance) { FactoryGirl.create(:attendance, event: event, status: :paid) }
            it 'confirms the attendance and sends the confirmation email' do
              EmailNotifications.expects(:registration_confirmed).once
              confirming.confirm
              expect(attendance.reload.status).to eq 'confirmed'
              expect(other_attendance.reload.status).to eq 'confirmed'
            end
          end
        end
      end

      context 'when grouped' do
        context 'and group has minimum size' do
          let(:group) { FactoryGirl.create(:registration_group, event: event, minimum_size: 5) }
          context 'and no completed' do
            let!(:attendance) { FactoryGirl.create(:attendance, event: event, registration_group: group, status: :paid) }
            let!(:pending) { FactoryGirl.create(:attendance, event: event, registration_group: group, status: :pending) }
            let!(:accepted) { FactoryGirl.create(:attendance, event: event, registration_group: group, status: :accepted) }
            let!(:confirmed) { FactoryGirl.create(:attendance, event: event, registration_group: group, status: :confirmed) }
            let!(:cancelled) { FactoryGirl.create(:attendance, event: event, registration_group: group, status: :cancelled) }
            it 'not confirms the attendance' do
              EmailNotifications.expects(:registration_confirmed).never
              confirming.confirm
              expect(attendance.reload.status).to eq 'paid'
              expect(pending.reload.status).to eq 'pending'
              expect(accepted.reload.status).to eq 'accepted'
              expect(confirmed.reload.status).to eq 'confirmed'
              expect(cancelled.reload.status).to eq 'cancelled'
            end
          end

          context 'and completed' do
            let!(:attendances) { FactoryGirl.create_list(:attendance, 5, event: event, registration_group: group, status: :paid) }
            it 'confirms the attendance and sends the confirmation email' do
              EmailNotifications.expects(:registration_confirmed).times(5)
              confirming.confirm
              expect(Attendance.all.pluck(:status)).to eq %w(confirmed confirmed confirmed confirmed confirmed)
            end
          end
        end
      end
    end
  end
end
