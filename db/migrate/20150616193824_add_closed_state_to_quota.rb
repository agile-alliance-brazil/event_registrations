class AddClosedStateToQuota < ActiveRecord::Migration[4.2]
  def change
    add_column :registration_quota, :closed, :boolean, default: false
  end
end
