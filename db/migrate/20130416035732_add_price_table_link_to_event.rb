class AddPriceTableLinkToEvent < ActiveRecord::Migration[4.2]
  def change
    add_column :events, :price_table_link, :string
  end
end
