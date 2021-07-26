# frozen_string_literal: true

Fabricator(:slack_configuration, from: 'Slack::SlackConfiguration') do
  event
  room_webhook 'foo'
end
