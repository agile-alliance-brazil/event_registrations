class AddColumnPaidInAdvanceToGroup < ActiveRecord::Migration
  def change
    change_table :registration_groups do |t|
      t.belongs_to :registration_quota
      t.boolean :paid_in_advance, default: false
    end
  end
end
