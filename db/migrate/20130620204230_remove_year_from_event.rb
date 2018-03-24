# frozen_string_literal: true

class RemoveYearFromEvent < ActiveRecord::Migration[4.2]
  def change
    remove_column :events, :year, :integer
  end
end
