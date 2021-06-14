# frozen_string_literal: true

class ChangeGenderToEnumAndAddingNewFieldsToAttendance < ActiveRecord::Migration[6.0]
  def up
    execute('INSERT INTO users (email, first_name, last_name, gender, encrypted_password, sign_in_count, created_at, updated_at) SELECT DISTINCT ON (email) email, first_name, last_name, gender, md5(random()::text), 0, created_at, updated_at FROM attendances a WHERE a.email NOT IN (SELECT email FROM users);')

    execute('UPDATE attendances a SET user_id = (SELECT id FROM users u WHERE u.email = a.email)')

    execute("UPDATE users SET gender = '0' WHERE gender = 'M'")
    execute("UPDATE users SET gender = '2' WHERE gender = 'F'")
    execute("UPDATE users SET gender = '5' WHERE gender = 'O' OR gender IS NULL OR gender = ''")

    execute("UPDATE attendances SET years_of_experience = '0' WHERE years_of_experience IS NULL OR years_of_experience = ''")
    execute("UPDATE attendances SET years_of_experience = '1' WHERE years_of_experience = '0 - 5'")
    execute("UPDATE attendances SET years_of_experience = '2' WHERE years_of_experience = '6 - 10'")
    execute("UPDATE attendances SET years_of_experience = '3' WHERE years_of_experience = '11 - 20'")
    execute("UPDATE attendances SET years_of_experience = '4' WHERE years_of_experience = '21 - 30'")
    execute("UPDATE attendances SET years_of_experience = '5' WHERE years_of_experience = '31 -'")

    execute("UPDATE attendances SET experience_in_agility = '0' WHERE experience_in_agility IS NULL OR experience_in_agility = ''")
    execute("UPDATE attendances SET experience_in_agility = '1' WHERE experience_in_agility = '0 - 2'")
    execute("UPDATE attendances SET experience_in_agility = '2' WHERE experience_in_agility = '3 - 7'")
    execute("UPDATE attendances SET experience_in_agility = '3' WHERE experience_in_agility = '7 -'")

    execute("UPDATE attendances SET organization_size = '0' WHERE organization_size IS NULL OR organization_size = ''")
    execute("UPDATE attendances SET organization_size = '1' WHERE organization_size = '1 - 10'")
    execute("UPDATE attendances SET organization_size = '2' WHERE organization_size = '11 - 30'")
    execute("UPDATE attendances SET organization_size = '3' WHERE organization_size = '31 - 100'")
    execute("UPDATE attendances SET organization_size = '4' WHERE organization_size = '100 - 500'")
    execute("UPDATE attendances SET organization_size = '4' WHERE organization_size = '500 -'")

    execute("UPDATE attendances SET education_level = '0' WHERE education_level IS NULL OR education_level = ''")
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
      t.string :school
      t.integer :ethnicity, default: 0, null: false, index: true
      t.integer :disability, default: 5, null: false, index: true

      t.remove :twitter_user
      t.remove :default_locale
      t.remove :organization
      t.remove :badge_name
      t.remove :neighbourhood
      t.remove :zipcode
      t.remove :address
      t.remove :phone
      t.remove :cpf
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

    change_table :events, bulk: true do |t|
      t.remove :logo
      t.remove :allow_voting
      t.remove :location_and_date
      t.remove :price_table_link
    end
  end

  def down
    change_table :users, bulk: true do |t|
      t.change :gender, :string

      t.remove :birth_date
      t.remove :education_level
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
      t.string :phone
      t.string :cpf
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

    execute("UPDATE attendances SET gender = 'M' WHERE gender = '0'")
    execute("UPDATE attendances SET gender = 'F' WHERE gender = '2'")
    execute("UPDATE attendances SET gender = '0' WHERE gender = '5'")

    execute("UPDATE users SET gender = 'M' WHERE gender = '0'")
    execute("UPDATE users SET gender = 'F' WHERE gender = '2'")
    execute("UPDATE users SET gender = '0' WHERE gender = '5'")

    change_table :events, bulk: true do |t|
      t.string :logo
      t.string :allow_voting
      t.string :location_and_date
      t.string :price_table_link
    end
  end
end
