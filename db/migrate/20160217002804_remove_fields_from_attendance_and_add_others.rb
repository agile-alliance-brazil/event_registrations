# frozen_string_literal: true

class RemoveFieldsFromAttendanceAndAddOthers < ActiveRecord::Migration[4.2]
  def change
    remove_column :attendances, :address, :string
    remove_column :attendances, :neighbourhood, :string
    remove_column :attendances, :twitter_user, :string
    remove_column :attendances, :zipcode, :string

    add_column :attendances, :organization_size, :string
    add_column :attendances, :job_role, :string
    add_column :attendances, :years_of_experience, :string
    add_column :attendances, :experience_in_agility, :string

    add_column :attendances, :school, :string
    add_column :attendances, :education_level, :string
  end
end
