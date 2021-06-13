# frozen_string_literal: true

class ChangeGennderToEnumAndAddingNewFieldsToAttendance < ActiveRecord::Migration[6.0]
  def up
    Attendance.all.each do |attendance|
      attendance_email = attendance.email.downcase
      user_email = attendance.email.downcase
      next unless attendance.email != user_email

      user = User.where('lower(email) = :attendance_email', attendance_email: attendance_email).first

      if user.present?
        attendance.update(user: user)
      else
        random_hex = SecureRandom.hex
        gender = case attendance.gender
                 when 'M'
                   '0'
                 when 'F'
                   '2'
                 else
                   '5'
                 end
        u = User.create(first_name: attendance.first_name, last_name: attendance.last_name, email: attendance_email, country: attendance.country,
                        state: attendance.state, city: attendance.city, gender: gender.to_i, password: random_hex, password_confirmation: random_hex, sign_in_count: 0)

        attendance.update(user: u)
      end
    end

    execute("UPDATE attendances SET gender = '0' WHERE gender = 'M'")
    execute("UPDATE attendances SET gender = '2' WHERE gender = 'F'")
    execute("UPDATE attendances SET gender = '5' WHERE gender = 'O'")

    execute("UPDATE attendances SET years_of_experience = '0' WHERE years_of_experience IS NULL")
    execute("UPDATE attendances SET years_of_experience = '0' WHERE years_of_experience = ''")
    execute("UPDATE attendances SET years_of_experience = '1' WHERE years_of_experience = '0 - 5'")
    execute("UPDATE attendances SET years_of_experience = '2' WHERE years_of_experience = '6 - 10'")
    execute("UPDATE attendances SET years_of_experience = '3' WHERE years_of_experience = '11 - 20'")
    execute("UPDATE attendances SET years_of_experience = '4' WHERE years_of_experience = '21 - 30'")
    execute("UPDATE attendances SET years_of_experience = '5' WHERE years_of_experience = '31 -'")

    execute("UPDATE attendances SET experience_in_agility = '0' WHERE experience_in_agility IS NULL")
    execute("UPDATE attendances SET experience_in_agility = '0' WHERE experience_in_agility = ''")
    execute("UPDATE attendances SET experience_in_agility = '1' WHERE experience_in_agility = '0 - 2'")
    execute("UPDATE attendances SET experience_in_agility = '2' WHERE experience_in_agility = '3 - 7'")
    execute("UPDATE attendances SET experience_in_agility = '3' WHERE experience_in_agility = '7 -'")

    execute("UPDATE attendances SET organization_size = '0' WHERE organization_size IS NULL")
    execute("UPDATE attendances SET organization_size = '0' WHERE organization_size = ''")
    execute("UPDATE attendances SET organization_size = '1' WHERE organization_size = '1 - 10'")
    execute("UPDATE attendances SET organization_size = '2' WHERE organization_size = '11 - 30'")
    execute("UPDATE attendances SET organization_size = '3' WHERE organization_size = '31 - 100'")
    execute("UPDATE attendances SET organization_size = '4' WHERE organization_size = '100 - 500'")
    execute("UPDATE attendances SET organization_size = '4' WHERE organization_size = '500 -'")

    execute("UPDATE attendances SET education_level = '0' WHERE education_level IS NULL")
    execute("UPDATE attendances SET education_level = '0' WHERE education_level = ''")
    execute("UPDATE attendances SET education_level = '1' WHERE education_level = 'Primary education'")
    execute("UPDATE attendances SET education_level = '2' WHERE education_level = 'Lower secondary education'")
    execute("UPDATE attendances SET education_level = '2' WHERE education_level = 'Secondary education'")
    execute("UPDATE attendances SET education_level = '2' WHERE education_level = 'Upper secondary education'")
    execute("UPDATE attendances SET education_level = '3' WHERE education_level = 'Post-secondary non-tertiary education'")
    execute("UPDATE attendances SET education_level = '4' WHERE education_level = 'Short-cycle tertiary education'")
    execute("UPDATE attendances SET education_level = '5' WHERE education_level = 'Bachelor or equivalent'")
    execute("UPDATE attendances SET education_level = '6' WHERE education_level = 'Master or equivalent'")
    execute("UPDATE attendances SET education_level = '7' WHERE education_level = 'Doctoral or equivalent'")

    change_table :users, bulk: true do |t|
      t.change_default :gender, nil
      t.change :gender, :integer, using: 'gender::integer'
      t.change_default :gender, 5

      t.date :birth_date, null: true
      t.integer :education_level, default: 0, index: true
      t.integer :job_role, default: 0, null: true, index: true
      t.string :other_job_role
      t.string :school
      t.integer :ethnicity, default: 0, null: false, index: true
      t.integer :disability, default: 0, null: false, index: true

      t.remove :twitter_user
      t.remove :default_locale
      t.remove :organization
      t.remove :badge_name
      t.remove :neighbourhood
      t.remove :zipcode
      t.remove :address
    end
    add_index :users, :gender

    User.all.each do |u|
      u.update(school: u.attendances.order(:registration_date).last&.school)
    end

    change_table :attendances, bulk: true do |t|
      t.change_default :years_of_experience, nil
      t.change :years_of_experience, :integer, using: 'years_of_experience::integer'
      t.change_default :years_of_experience, 0

      t.change_default :experience_in_agility, nil
      t.change :experience_in_agility, :integer, using: 'experience_in_agility::integer'
      t.change_default :experience_in_agility, 0

      t.change_default :education_level, nil
      t.change :education_level, :integer, using: 'education_level::integer'
      t.change_default :education_level, 0

      t.change_default :organization_size, nil
      t.change :organization_size, :integer, using: 'organization_size::integer'
      t.change_default :organization_size, 0

      t.integer :source_of_interest, default: 0, null: false, index: true

      t.remove :gender
      t.remove :cpf
      t.remove :email
      t.remove :first_name
      t.remove :last_name
      t.remove :phone
      t.remove :school
    end

    add_index :attendances, :education_level
    add_index :attendances, :years_of_experience
  end

  def down
    change_table :users, bulk: true do |t|
      t.remove :birth_date
      t.remove :education_level
      t.remove :job_role
      t.remove :other_job_role
      t.remove :school
      t.remove :disability
      t.remove :ethnicity

      t.string :twitter_user
      t.string :default_locale
      t.string :organization
      t.string :badge_name
      t.string :neighbourhood
      t.string :zipcode
      t.string :address
    end

    remove_index :users, :gender

    change_table :attendances, bulk: true do |t|
      t.remove :source_of_interest
      t.change :years_of_experience, :string
      t.change :experience_in_agility, :string
      t.change :education_level, :string
      t.change :organization_size, :string

      t.string :gender
      t.string :cpf
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :school
    end

    remove_index :attendances, :education_level
    remove_index :attendances, :years_of_experience

    execute('UPDATE attendances SET email = subquery.email FROM (SELECT id, email FROM users) AS subquery WHERE attendances.user_id = subquery.id')

    execute("UPDATE attendances SET years_of_experience = NULL WHERE years_of_experience = '0'")
    execute("UPDATE attendances SET years_of_experience = '0 - 5' WHERE years_of_experience = '1'")
    execute("UPDATE attendances SET years_of_experience = '6 - 10' WHERE years_of_experience = '2'")
    execute("UPDATE attendances SET years_of_experience = '11 - 20' WHERE years_of_experience = '3'")
    execute("UPDATE attendances SET years_of_experience = '21 - 30' WHERE years_of_experience = '4'")
    execute("UPDATE attendances SET years_of_experience = '31 -' WHERE years_of_experience = '5'")

    execute("UPDATE attendances SET experience_in_agility = NULL WHERE experience_in_agility = '0'")
    execute("UPDATE attendances SET experience_in_agility = '0 - 2' WHERE experience_in_agility = '1'")
    execute("UPDATE attendances SET experience_in_agility = '3 - 7' WHERE experience_in_agility = '2'")
    execute("UPDATE attendances SET experience_in_agility = '7 -' WHERE experience_in_agility = '3'")

    execute("UPDATE attendances SET organization_size = NULL WHERE organization_size = '0'")
    execute("UPDATE attendances SET organization_size = '1 - 10' WHERE organization_size = '1'")
    execute("UPDATE attendances SET organization_size = '11 - 30' WHERE organization_size = '2'")
    execute("UPDATE attendances SET organization_size = '31 - 100' WHERE organization_size = '3'")
    execute("UPDATE attendances SET organization_size = '100 - 500' WHERE organization_size = '4'")

    execute("UPDATE attendances SET education_level = NULL WHERE education_level = '0'")
    execute("UPDATE attendances SET education_level = 'Primary education' WHERE education_level = '1'")
    execute("UPDATE attendances SET education_level = 'Secondary education' WHERE education_level = '2'")
    execute("UPDATE attendances SET education_level = 'Post-secondary non-tertiary education' WHERE education_level = '3'")
    execute("UPDATE attendances SET education_level = 'Short-cycle tertiary education' WHERE education_level = '4'")
    execute("UPDATE attendances SET education_level = 'Bachelor or equivalent' WHERE education_level = '5'")
    execute("UPDATE attendances SET education_level = 'Master or equivalent' WHERE education_level = '6'")
    execute("UPDATE attendances SET education_level = 'Doctoral or equivalent' WHERE education_level = '7'")
  end
end
