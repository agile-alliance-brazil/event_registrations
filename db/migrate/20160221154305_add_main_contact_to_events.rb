class AddMainContactToEvents < ActiveRecord::Migration
  def change
    add_column :events, :main_email_contact, :string, default: '', null: false
  end
end
