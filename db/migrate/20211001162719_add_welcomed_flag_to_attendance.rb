# frozen_string_literal: true

class AddWelcomedFlagToAttendance < ActiveRecord::Migration[6.0]
  def change
    change_table :attendances, bulk: true do |t|
      t.boolean :welcome_email_sent, default: false

      t.integer :lock_version
    end
  end
end
