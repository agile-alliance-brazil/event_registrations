# frozen_string_literal: true

require 'payment_gateway_adapter'

class PagSeguroAdapter < PaymentGatewayAdapter
  def self.from_attendance(attendance)
    items = PaymentGatewayAdapter.from_attendance(attendance, PagSeguroItem)
    new(items, attendance)
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
