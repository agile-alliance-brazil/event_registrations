class AddAutomaticApprovalToRegistrationGroups < ActiveRecord::Migration
  def change
    add_column :registration_groups, :automatic_approval, :boolean, default: false
  end
end
