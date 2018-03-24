# frozen_string_literal: true

class AddStatusToInvoice < ActiveRecord::Migration[4.2]
  def change
    add_column :invoices, :status, :string
  end
end
