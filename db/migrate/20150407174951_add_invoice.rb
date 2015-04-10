class AddInvoice < ActiveRecord::Migration
  def change

    create_table :invoices do |t|
      t.integer :frete

      t.belongs_to :attendance
      t.belongs_to :registration_group
    end
  end
end
