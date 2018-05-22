# frozen_string_literal: true

class PaymentGatewayAdapter
  class << self
    def from_attendance(attendance, item_class)
      create_items(attendance, item_class)
    end

    private

    def create_items(attendance, item_class)
      [].tap do |items|
        items << item_class.send(:new, attendance.full_name, attendance.id, attendance.registration_value)
      end
    end
  end

  attr_reader :items, :attendance

  def initialize(items, target)
    @items = items
    @attendance = target
  end

  def to_variables
    {}.tap do |vars|
      @items.each_with_index do |item, index|
        vars.merge!(item.to_variables(index + 1))
      end
      add_variables(vars)
    end
  end

  class Item
    attr_reader :name, :number, :amount, :quantity

    def initialize(name, number, amount, quantity = 1)
      @name = name
      @number = number
      @amount = amount
      @quantity = quantity
    end
  end
end
