# frozen_string_literal: true

class AddScheduleLinkAndRemoteToEvent < ActiveRecord::Migration[6.0]
  def change
    change_table :events, bulk: true do |t|
      t.string :event_nickname
      t.string :event_schedule_link
      t.string :event_remote_manual_link
      t.string :event_remote_platform_name
      t.string :event_remote_platform_mail
      t.boolean :event_remote, default: false
    end
  end
end
