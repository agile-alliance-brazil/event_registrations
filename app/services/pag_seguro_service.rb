# frozen_string_literal: true

class PagSeguroService
  ENVIRONMENT = Rails.env.production? ? :production : :sandbox

  def self.config
    PagSeguro.configure do |config|
      config.token = Figaro.env.pag_seguro_token
      config.email = Figaro.env.pag_seguro_email
    end
  end

  def self.checkout(attendance, payment_request)
    payment_request.reference = attendance.id

    payment_request.items << {
      id: attendance.id,
      description: attendance.full_name,
      amount: attendance.registration_value,
      weight: 0
    }

    response = payment_request.register
    responds(response)
  end

  def self.responds(response)
    response_hash = {}
    if response.present? && response.errors.present?
      response_hash[:errors] = response.errors.join('\n')
    elsif response.blank?
      response_hash[:errors] = 'Internal server error'
    else
      response_hash = { url: response.url }
    end

    response_hash
  end
end
