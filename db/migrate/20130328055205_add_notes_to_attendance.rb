class AddNotesToAttendance < ActiveRecord::Migration[4.2]
  def change
    add_column :attendances, :notes, :string
  end
end
