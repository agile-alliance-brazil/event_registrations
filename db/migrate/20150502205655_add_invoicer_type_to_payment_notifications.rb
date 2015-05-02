class AddInvoicerTypeToPaymentNotifications < ActiveRecord::Migration
  def change
    add_column :payment_notifications, :invoicer_type, :string

    PaymentNotification.all.each do |payment_notification|
      payment_notification.invoicer_type = "Attendance"
      payment_notification.save!
    end
  end
end
