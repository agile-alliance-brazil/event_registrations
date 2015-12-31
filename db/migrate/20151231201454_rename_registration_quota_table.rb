class RenameRegistrationQuotaTable < ActiveRecord::Migration
  def change
    rename_table :registration_quota, :registration_quotas
  end
end
