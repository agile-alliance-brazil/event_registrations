class AddGroup < ActiveRecord::Migration
  def change
    change_table :attendances do |t|
      t.remove :registration_groups_id if column_exists?(:attendances, :registration_groups_id)
    end

    change_table :users do |t|
      t.remove :registration_groups_id if column_exists?(:users, :registration_groups_id)
    end

    drop_table :registration_groups if ActiveRecord::Base.connection.table_exists? 'registration_groups'

    create_table :registration_groups do |t|
      t.references	:event

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
