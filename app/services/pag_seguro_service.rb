class PagSeguroService
  def self.checkout(invoice, payment_request)
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
    if response.present? && response.errors.any?
      response_hash[:errors] = response.errors.join('\n')
    elsif response.blank?
      response_hash[:errors] = 'Internal server error'
    end
    response_hash
  end
end