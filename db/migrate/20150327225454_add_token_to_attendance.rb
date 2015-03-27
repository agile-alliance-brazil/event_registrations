class AddTokenToAttendance < ActiveRecord::Migration
  def change
    add_column :attendances, :registration_token, :string
  end
end
