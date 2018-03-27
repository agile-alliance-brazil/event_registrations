# frozen_string_literal: true

class GeneratePaymentTypeReport
  def self.run_for(event)
    return {} if event.blank?
    event.attendances.non_free.committed_to.order(:registration_value, :payment_type).group(:payment_type, :registration_value).count(:id)
  end
end
