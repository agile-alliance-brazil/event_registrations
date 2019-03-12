# frozen_string_literal: true

class AddDeviseToUsers < ActiveRecord::Migration[5.2]
  def self.up
    con = ActiveRecord::Base.connection

    ## Remove invalid users
    con.execute('UPDATE users u LEFT JOIN attendances a on a.user_id = u.id SET u.email = a.email WHERE u.email IS NULL;')
    con.execute('DELETE FROM users WHERE email IS NULL')

    result_for_emails = con.select_all('SELECT u.email FROM users u WHERE email IS NOT NULL GROUP BY u.email HAVING COUNT(1) >= 2')
    result_for_emails.map do |email|
      result_for_ids = con.select_all("SELECT u.id AS user_id FROM users u WHERE u.email = #{con.quote(email['email'])}")

      user_ids_array = result_for_ids.map { |result_id| result_id['user_id'] }

      result_user_to_keep = con.select_all("SELECT a.user_id AS user_id FROM attendances a WHERE a.user_id IN (#{user_ids_array.join(',')}) ORDER BY a.id DESC LIMIT 1")
      user_to_keep = result_user_to_keep[0]['user_id']

      con.execute("UPDATE attendances a SET a.user_id = #{user_to_keep} WHERE a.user_id IN (#{user_ids_array.join(',')})")

      users_to_delete = [user_ids_array - [user_to_keep]].flatten.join(',')

      con.execute("DELETE FROM users WHERE id IN (#{users_to_delete})")
    end

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

    remove_column :users, :role
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

    change_column_null :users, :first_name, true
    change_column_null :users, :last_name, true
    change_column_null :users, :email, true
  end
end
