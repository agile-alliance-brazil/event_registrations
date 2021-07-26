# frozen_string_literal: true

RSpec.describe Slack::SlackNotificationService, type: :service do
  describe '#notify_new_registration' do
    let(:event) { Fabricate :event }
    let!(:slack_config) { Fabricate :slack_configuration, event: event, room_webhook: 'http://foo.com' }
    let!(:slack_notifier) { Slack::Notifier.new(slack_config.room_webhook) }
    let(:attendance) { Fabricate :attendance, event: event }

    context 'with no exceptions' do
      it 'calls slack notification method' do
        expect_any_instance_of(Slack::Notifier).to receive(:ping).once
        described_class.instance.notify_new_registration(slack_notifier, attendance)
      end
    end

    context 'with exceptions' do
      it 'calls slack notification method' do
        allow(slack_notifier).to(receive(:ping)).and_raise(Slack::Notifier::APIError)
        expect(Rails.logger).to(receive(:error)).once
        described_class.instance.notify_new_registration(slack_notifier, attendance)
      end
    end
  end
end
