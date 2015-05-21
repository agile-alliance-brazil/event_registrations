class AddRelationToInvoice < ActiveRecord::Migration
  def change
    add_foreign_key :registration_groups, :invoices
  end
end
