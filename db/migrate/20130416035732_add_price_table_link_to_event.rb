class AddPriceTableLinkToEvent < ActiveRecord::Migration
  def change
    add_column :events, :price_table_link, :string
  end
end
