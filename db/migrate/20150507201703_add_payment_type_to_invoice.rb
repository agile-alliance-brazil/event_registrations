class AddPaymentTypeToInvoice < ActiveRecord::Migration
  def change
    add_column(:invoices, :payment_type, :string)
  end
end
