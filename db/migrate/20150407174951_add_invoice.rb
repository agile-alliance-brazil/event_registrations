class AddInvoice < ActiveRecord::Migration
  def change

    create_table :invoices do |t|
      t.integer :frete
      t.string :email
      t.string :name
      t.string :cpf
      t.string :gender
      t.string :phone
      t.string :address
      t.string :neighbourhood
      t.string :city
      t.string :state
      t.string :zipcode

      t.belongs_to :attendance
      t.belongs_to :registration_group
    end
  end
end
