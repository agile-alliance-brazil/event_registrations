# frozen_string_literal: true

RSpec.describe Slack::SlackConfiguration, type: :model do
  context 'associations' do
    it { is_expected.to belong_to :event }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of :room_webhook }
  end
end
