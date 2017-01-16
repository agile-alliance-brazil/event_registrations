class RemoveYearFromEvent < ActiveRecord::Migration
  def change
    remove_column :events, :year, :integer
  end
end
