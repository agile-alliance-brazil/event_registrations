class RenameRegistrationQuotaTable < ActiveRecord::Migration
  def change
    remove_foreign_key :events, :registration_quota
    remove_foreign_key :attendances, :registration_quota

    rename_table :registration_quota, :registration_quotas

    add_foreign_key :events, :registration_quotas
    add_foreign_key :attendances, :registration_quotas
  end
end
