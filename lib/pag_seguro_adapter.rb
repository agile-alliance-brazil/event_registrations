require 'payment_gateway_adapter'

class PagSeguroAdapter < PaymentGatewayAdapter
  def self.from_invoice(invoice)
    items = PaymentGatewayAdapter.from_invoice(invoice, PagSeguroItem)
    self.new(items, invoice)
  end

  def add_variables(vars)

  end

  class PagSeguroItem < Item
    def to_variables(index)
      {
        'id' => number,
        'description' => name,
        'weight' => 0,
        'amount' => amount
      }
    end
  end
end
