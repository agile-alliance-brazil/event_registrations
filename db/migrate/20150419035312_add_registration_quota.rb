class AddRegistrationQuota < ActiveRecord::Migration
  def change
    create_table :registration_quota do |t|
      t.integer :quota
      t.timestamps

      t.references :event
      t.references :registration_price
    end
  end
end
