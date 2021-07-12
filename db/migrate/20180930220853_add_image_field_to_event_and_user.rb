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

    add_column :attendances, :registered_by_id, :integer
    add_index :attendances, :registered_by_id
    execute('UPDATE attendances SET registered_by_id = user_id')
    change_column_null :attendances, :registered_by_id, false

    add_foreign_key :attendances, :users, column: :registered_by_id
  end

  def down
    remove_column :attendances, :registered_by_id

    remove_column :events, :city
    remove_column :events, :state
    remove_column :events, :country

    remove_column :users, :user_image
    remove_column :events, :event_image
  end
end
