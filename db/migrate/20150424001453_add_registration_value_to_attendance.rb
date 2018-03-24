# frozen_string_literal: true

class AddRegistrationValueToAttendance < ActiveRecord::Migration[4.2]
  def change
    add_column(:attendances, :registration_value, :decimal)
  end
end
