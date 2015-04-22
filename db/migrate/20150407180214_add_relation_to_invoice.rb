class AddRelationToInvoice < ActiveRecord::Migration
  def change
    add_foreign_key :attendances, :invoices, :integer
    add_foreign_key :registration_groups, :invoices, :integer
  end
end
