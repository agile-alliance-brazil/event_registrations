class GeneratePaymentTypeReport
  def self.run_for(event)
    return {} unless event.present?
    event.attendances.already_paid.group('payment_type').sum(:registration_value)
  end

  def self.count_for(event)
    return {} unless event.present?
    event.attendances.non_free.already_paid.group('payment_type').count(:id)
  end
end