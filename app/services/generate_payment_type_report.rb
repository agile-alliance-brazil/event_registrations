class GeneratePaymentTypeReport
  def self.run_for(event)
    return {} unless event.present?
    event.attendances.already_paid.joins(:invoices).group('invoices.payment_type').sum(:registration_value)
  end
end