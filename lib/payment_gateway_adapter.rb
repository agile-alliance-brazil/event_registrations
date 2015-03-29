# encoding: UTF-8
class PaymentGatewayAdapter
  class << self
    def from_attendance(attendance, item_class)
      registration_desc = lambda do |attendee|
        "#{I18n.t('formtastic.labels.attendance.registration_type_id')}: #{I18n.t(attendance.registration_type.title)}"
      end
      create_items(attendance, item_class, registration_desc)
    end
    
    private
    def create_items(attendee, item_class, registration_desc)
      [].tap do |items|
        items << item_class.send(:new, CGI.escapeHTML(registration_desc.call(attendee)),
          attendee.registration_type.id,
          attendee.registration_fee
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
        vars.merge!(item.to_variables(index + 1))
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
