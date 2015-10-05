class PagSeguroService
  ENVIRONMENT = Rails.env.production? ? :production : :sandbox

  def self.config
    PagSeguro.configure do |config|
      config.token = APP_CONFIG[:pag_seguro][:token]
      config.email = APP_CONFIG[:pag_seguro][:email]
    end
  end

  def self.checkout(invoice, payment_request)
    payment_request.reference = invoice.id

    payment_request.items << {
        id: invoice.id,
        description: invoice.name,
        amount: invoice.amount,
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