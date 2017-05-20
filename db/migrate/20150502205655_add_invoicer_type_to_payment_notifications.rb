class AddInvoicerTypeToPaymentNotifications < ActiveRecord::Migration[4.2]
  def change
    add_column(:payment_notifications, :invoicer_type, :string) unless column_exists?(:payment_notifications, :invoicer_type)

    PaymentNotification.all.each do |payment_notification|
      payment_notification.invoicer_type = 'Attendance'
      payment_notification.save(validate: false)
    end
  end
end
