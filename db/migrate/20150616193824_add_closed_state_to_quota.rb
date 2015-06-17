class AddClosedStateToQuota < ActiveRecord::Migration
  def change
    add_column :registration_quota, :closed, :boolean, default: false
  end
end
