require 'payment_gateway_adapter'

class PagSeguroAdapter < PaymentGatewayAdapter
  def self.from_invoice(invoice)
    items = PaymentGatewayAdapter.from_invoice(invoice, PagSeguroItem)
    new(items, invoice)
  end

  def add_variables(_vars); end

  class PagSeguroItem < Item
    def to_variables(index)
      {
        "id_#{index}" => number,
        "description_#{index}" => name,
        "weight_#{index}" => 0,
        "quantity_#{index}" => 1,
        "amount_#{index}" => amount
      }
    end
  end
end
