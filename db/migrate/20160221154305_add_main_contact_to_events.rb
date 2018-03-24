# frozen_string_literal: true

class AddMainContactToEvents < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :main_email_contact, :string, default: '', null: false
  end
end
