class AddMinimumSizeToGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :registration_groups, :minimum_size, :integer
  end
end
