# frozen_string_literal: true

class RenameRegistrationQuota < ActiveRecord::Migration[4.2]
  def up
    rename_table :registration_quota, :registration_quotas

    change_column :attendances, :registration_value, :decimal, precision: 10, decimal: 2
  end

  def down
    rename_table :registration_quotas, :registration_quota

    change_column :attendances, :registration_value, :integer
  end
end
