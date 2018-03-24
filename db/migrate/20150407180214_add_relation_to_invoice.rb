# frozen_string_literal: true

class AddRelationToInvoice < ActiveRecord::Migration[4.2]
  def change
    add_column :registration_groups, :invoice_id, :integer
    add_foreign_key :registration_groups, :invoices
  end
end
