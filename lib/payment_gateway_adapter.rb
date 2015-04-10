# encoding: UTF-8
class PaymentGatewayAdapter
  class << self
    def from_invoice(invoice, item_class)
      create_items(invoice, item_class)
    end

    private

    def create_items(invoice, item_class)
      [].tap do |items|
        items << item_class.send(:new, invoice.name,
          invoice.registration_type.id,
          invoice.amount
        )
      end
    end
  end

  attr_reader :items, :invoice

  def initialize(items, target)
    @items, @invoice = items, target
  end

  def to_variables
    {}.tap do |vars|
      @items.each_with_index do |item, index|
        vars.merge!(item.to_variables(index+1))
      end
      add_variables(vars)
    end
  end

  class Item
    attr_reader :name, :number, :amount, :quantity

    def initialize(name, number, amount, quantity = 1)
      @name, @number, @amount, @quantity = name, number, amount, quantity
    end
  end
end
