class AddFullPriceToEvent < ActiveRecord::Migration[4.2]
  def change
    add_column(:events, :full_price, :decimal)
  end
end
