# frozen_string_literal: true

# == Schema Information
#
# Table name: slack_configurations
#
#  created_at   :datetime         not null
#  event_id     :integer          not null, indexed
#  id           :bigint(8)        not null, primary key
#  room_webhook :string           not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_slack_configurations_on_event_id  (event_id)
#
# Foreign Keys
#
#  fk_rails_9dbb8d5cb7  (event_id => events.id)
#

module Slack
  class SlackConfiguration < ApplicationRecord
    belongs_to :event

    validates :room_webhook, presence: true
  end
end
