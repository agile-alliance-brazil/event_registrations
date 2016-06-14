class RemovePaymentTypeFromAttendance < ActiveRecord::Migration
  def change
    remove_column :attendances, :payment_type, :string
  end
end
