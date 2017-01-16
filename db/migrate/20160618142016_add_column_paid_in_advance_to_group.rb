class AddColumnPaidInAdvanceToGroup < ActiveRecord::Migration
  def change
    add_reference(:registration_groups, :registration_quota)
    add_column(:registration_groups, :paid_in_advance, :boolean, default: false)
  end
end
