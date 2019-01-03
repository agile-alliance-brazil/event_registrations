# frozen_string_literal: true

class AddDeviseToUsers < ActiveRecord::Migration[5.2]
  def self.up
    ## Remove duplicates in email field
    execute('UPDATE users u LEFT JOIN attendances a on a.user_id = u.id SET u.email = a.email WHERE u.email IS NULL;')
    duplicated_emails = User.select('users.email').having('COUNT(1) >= 2').where('email IS NOT NULL').group(:email).order(:email)
    duplicated_emails.map do |value|
      next if value.blank?

      users_duplicated = User.where(email: value.email)
      attendances_to_duplicated_users = Attendance.where(user_id: users_duplicated.map(&:id))
      last_attendance_id = attendances_to_duplicated_users.map(&:id).max
      valid_user = Attendance.find(last_attendance_id).user
      attendances_to_duplicated_users.each { |attendance| attendance.update(user_id: valid_user.id) }
      [users_duplicated - [valid_user]].flatten.map(&:destroy)
    end

    User.where(email: nil).map(&:destroy)

    change_table :users do |t|
      t.integer :role, default: 0, null: false

      ## Database authenticatable
      t.string :encrypted_password, null: false, default: ''

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at
    end

    change_column_null :users, :first_name, false
    change_column_null :users, :last_name, false
    change_column_null :users, :email, false

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
    add_index :users, :unlock_token,         unique: true
  end

  def self.down
    remove_index :users, :email
    remove_index :users, :reset_password_token
    remove_index :users, :confirmation_token
    remove_index :users, :unlock_token

    remove_column :users, :encrypted_password
    remove_column :users, :reset_password_token
    remove_column :users, :reset_password_sent_at
    remove_column :users, :remember_created_at
    remove_column :users, :sign_in_count
    remove_column :users, :current_sign_in_at
    remove_column :users, :last_sign_in_at
    remove_column :users, :current_sign_in_ip
    remove_column :users, :last_sign_in_ip
    remove_column :users, :confirmation_token
    remove_column :users, :confirmed_at
    remove_column :users, :confirmation_sent_at
    remove_column :users, :unconfirmed_email
    remove_column :users, :failed_attempts
    remove_column :users, :unlock_token
    remove_column :users, :locked_at
  end
end
