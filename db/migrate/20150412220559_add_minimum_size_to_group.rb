class AddMinimumSizeToGroup < ActiveRecord::Migration
  def change
    add_column :registration_groups, :minimum_size, :integer
  end
end
