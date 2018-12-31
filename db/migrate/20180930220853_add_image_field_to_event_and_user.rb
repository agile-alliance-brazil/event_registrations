# frozen_string_literal: true

class AddImageFieldToEventAndUser < ActiveRecord::Migration[5.2]
  def up
    add_column :events, :event_image, :string
    add_column :users, :user_image, :string

    add_column :events, :country, :string
    add_column :events, :state, :string
    add_column :events, :city, :string

    execute("UPDATE events SET country = 'ZZ'")
    execute("UPDATE events SET city = 'default'")
    execute("UPDATE events SET state = 'ZZ'")

    change_column_null :events, :country, false
    change_column_null :events, :state, false
    change_column_null :events, :city, false
  end

  def down
    remove_column :events, :event_image
    remove_column :events, :country
    remove_column :events, :state
    remove_column :events, :city

    remove_column :users, :user_image
  end
end
