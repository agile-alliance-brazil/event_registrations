# frozen_string_literal: true

class AddEventLinkAndImageToEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :link, :string
    add_column :events, :logo, :string
  end
end
