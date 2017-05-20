class AddAutomaticApprovalToRegistrationGroups < ActiveRecord::Migration[4.2]
  def change
    add_column :registration_groups, :automatic_approval, :boolean, default: false
  end
end
