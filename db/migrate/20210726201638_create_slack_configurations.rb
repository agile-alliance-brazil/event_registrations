# frozen_string_literal: true

class CreateSlackConfigurations < ActiveRecord::Migration[6.0]
  def change
    create_table :slack_configurations do |t|
      t.integer :event_id, null: false, index: true
      t.string :room_webhook, null: false

      t.timestamps
    end

    add_foreign_key :slack_configurations, :events, column: :event_id
  end
end
