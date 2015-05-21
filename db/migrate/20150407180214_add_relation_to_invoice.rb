class AddRelationToInvoice < ActiveRecord::Migration
  def change
    add_column :registration_groups, :invoice_id, :integer
    add_foreign_key :registration_groups, :invoices
  end
end
