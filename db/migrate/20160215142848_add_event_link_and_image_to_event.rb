class AddEventLinkAndImageToEvent < ActiveRecord::Migration
  def change
    add_column :events, :link, :string
    add_column :events, :logo, :string
  end
end
