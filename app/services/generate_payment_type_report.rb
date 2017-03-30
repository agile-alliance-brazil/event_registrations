class GeneratePaymentTypeReport
  def self.run_for(event)
    return {} if event.blank?
    event
      .attendances
      .non_free
      .already_paid
      .order(:registration_value, :payment_type)
      .group(:payment_type, :registration_value)
      .count(:id)
  end
end
