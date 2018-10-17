# frozen_string_literal: true

class AddImageFieldToEventAndUser < ActiveRecord::Migration[5.2]
  def up
    add_column :events, :event_image, :string
    execute("UPDATE events SET event_image = 'default'")

    add_column :users, :user_image, :string
    execute("UPDATE users SET user_image = 'default'")
  end

  def down
    remove_column :events, :event_image
    remove_column :users, :user_image
  end
end
