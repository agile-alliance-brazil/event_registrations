class AddAdvisedToAttendance < ActiveRecord::Migration[4.2]
  def change
    add_column :attendances, :advised, :boolean, default: false
    add_column :attendances, :advised_at, :datetime
  end
end
