class RenameRegistrationQuota < ActiveRecord::Migration[4.2]
  def change
    rename_table :registration_quota, :registration_quotas

    change_column :attendances, :registration_value, :decimal, precision: 10, decimal: 2
  end
end
