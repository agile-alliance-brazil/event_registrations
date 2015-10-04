class GeneratePaymentTypeReport
  def self.run_for(event)
    return {} unless event.present?
    event.attendances.already_paid.joins(:invoices).group('invoices.payment_type').sum(:registration_value)
  end

  def self.count_for(event)
    return {} unless event.present?
    event.attendances.already_paid.joins(:invoices).group('invoices.payment_type').count(:id)
  end
end