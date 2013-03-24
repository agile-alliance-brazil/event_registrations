# encoding: UTF-8
require 'payment_gateway_adapter'

class PaypalAdapter < PaymentGatewayAdapter
  def self.from_attendance(attendance)
    PaymentGatewayAdapter.from_attendance(attendance, PaypalItem)
  end

  def add_variables(vars)
    vars['invoice'] = @invoice.id
  end
  
  class PaypalItem < Item
    def to_variables(index)
      {
        "amount_#{index}" => amount,
        "item_name_#{index}" => name,
        "item_number_#{index}" => number,
        "quantity_#{index}" => quantity
      }
    end
  end
end
