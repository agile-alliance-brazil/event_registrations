# frozen_string_literal: true

class AddGroup < ActiveRecord::Migration[4.2]
  def change
    remove_column(:attendances, :registration_groups_id, :integer) if column_exists?(:attendances, :registration_groups_id)

    remove_column(:users, :registration_groups_id, :integer) if column_exists?(:users, :registration_groups_id)

    if ActiveRecord::Base.connection.table_exists? 'registration_groups'
      drop_table :registration_groups do |t|
        t.references :event

        t.string :name
        t.integer :capacity
        t.integer :discount
        t.string :token

        t.timestamps

        t.references :leader
      end
    end

    create_table :registration_groups do |t|
      t.references :event

      t.string :name
      t.integer :capacity
      t.integer :discount
      t.string :token

      t.timestamps

      t.references :leader
    end

    add_column :users, :registration_group_id, :integer
    add_foreign_key :users, :registration_groups
  end
end
