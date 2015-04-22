class AddFullPriceToEvent < ActiveRecord::Migration
  def change
    add_column(:events, :full_price, :decimal)
  end
end
