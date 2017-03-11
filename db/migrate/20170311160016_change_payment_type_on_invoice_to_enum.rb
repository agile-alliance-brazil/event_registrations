class ChangePaymentTypeOnInvoiceToEnum < ActiveRecord::Migration
  def up
    add_column :invoices, :type_number, :integer
    execute("UPDATE invoices SET type_number = 1 WHERE payment_type='gateway'")
    execute("UPDATE invoices SET type_number = 2 WHERE payment_type='bank_deposit'")
    execute("UPDATE invoices SET type_number = 3 WHERE payment_type='statement_agreement'")

    change_column_null :invoices, :payment_type, true
    execute('UPDATE invoices SET payment_type = null')
    change_column :invoices, :payment_type, :integer

    execute('UPDATE invoices SET payment_type = type_number')

    change_column_null :invoices, :payment_type, false
    remove_column :invoices, :type_number
  end

  def down
    add_column :invoices, :type_string, :string
    execute("UPDATE invoices SET type_string = 'gateway' WHERE payment_type = 1")
    execute("UPDATE invoices SET type_string = 'bank_deposit' WHERE payment_type = 2")
    execute("UPDATE invoices SET type_string = 'statement_agreement' WHERE payment_type = 3")

    change_column_null :invoices, :payment_type, true
    execute('UPDATE invoices SET payment_type = null')
    change_column :invoices, :payment_type, :string

    execute('UPDATE invoices SET payment_type = type_string')

    change_column_null :invoices, :payment_type, false
    remove_column :invoices, :type_string
  end
end
