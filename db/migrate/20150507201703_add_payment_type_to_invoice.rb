class AddPaymentTypeToInvoice < ActiveRecord::Migration[4.2]
  def change
    add_column(:invoices, :payment_type, :string)
  end
end
