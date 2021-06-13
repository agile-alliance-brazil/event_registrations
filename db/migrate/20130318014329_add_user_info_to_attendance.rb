# frozen_string_literal: true

class AddUserInfoToAttendance < ActiveRecord::Migration[4.2]
  def change
    add_column :attendances, :first_name, :string
    add_column :attendances, :last_name, :string
    add_column :attendances, :email, :string
    add_column :attendances, :organization, :string
    add_column :attendances, :phone, :string
    add_column :attendances, :country, :string
    add_column :attendances, :state, :string
    add_column :attendances, :city, :string
    add_column :attendances, :badge_name, :string
    add_column :attendances, :cpf, :string
    add_column :attendances, :gender, :string
    add_column :attendances, :twitter_user, :string
    add_column :attendances, :address, :string
    add_column :attendances, :neighbourhood, :string
    add_column :attendances, :zipcode, :string
    Attendance.all.each do |attendance|
      common_attributes = attendance.user.attributes.reject do |attr_name, _value|
        attendance_attributes = %w[id created_at updated_at roles_mask]
        attendance_attributes.include?(attr_name)
      end
      attendance.update!(common_attributes)
    end
  end
end
