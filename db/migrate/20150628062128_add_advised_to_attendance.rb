class AddAdvisedToAttendance < ActiveRecord::Migration
  def change
    add_column :attendances, :advised, :boolean, default: false
    add_column :attendances, :advised_at, :datetime
  end
end
