class AddRelationToInvoice < ActiveRecord::Migration
  def change
    add_column :attendances, :invoice_id, :integer
    add_column :registration_groups, :invoice_id, :integer

    add_foreign_key :attendances, :invoices, :integer
    add_foreign_key :registration_groups, :invoices, :integer
  end
end
