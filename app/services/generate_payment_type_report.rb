class GeneratePaymentTypeReport
  def self.run_for(event)
    return {} unless event.present?
    report(event).sum(:registration_value)
  end

  def self.count_for(event)
    return {} unless event.present?
    report(event).count(:id)
  end

  def self.report(event)
    event.attendances.already_paid.group('payment_type')
  end
end