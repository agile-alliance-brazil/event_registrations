# frozen_string_literal: true

class AddColumnLastStatusChangeToAttendances < ActiveRecord::Migration[4.2]
  def change
    add_column :attendances, :last_status_change_date, :datetime
  end
end
