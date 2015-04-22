class AddGroup < ActiveRecord::Migration
  def change
    create_table :registration_groups do |t|
      t.references	:event

      t.string :name
      t.integer :capacity
      t.integer :discount
      t.string :token

      t.timestamps

      t.references :leader
    end

    add_foreign_key :users, :registration_groups
  end
end
