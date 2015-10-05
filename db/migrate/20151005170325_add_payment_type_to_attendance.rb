class AddPaymentTypeToAttendance < ActiveRecord::Migration
  def change
    add_column :attendances, :payment_type, :string

    Event.where('id > 11').each do |event|
      event.attendances.active.each do |attendance|
        invoice = attendance.invoices.active.last
        attendance.update(payment_type: invoice.payment_type) if invoice.present?
      end
    end
  end
end
