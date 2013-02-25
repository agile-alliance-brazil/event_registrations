# encoding: UTF-8
class PaypalAdapter
  class << self
    def from_attendance(attendance)
      registration_desc = lambda do |attendee|
        "#{I18n.t('formtastic.labels.attendance.registration_type_id')}: #{I18n.t(attendance.registration_type.title)}"
      end
      items = create_items(attendance, registration_desc)
      self.new(items, attendance)
    end
    
    private
    def create_items(attendee, registration_desc)
      [].tap do |items|
        items << PaypalItem.new(
          CGI.escapeHTML(registration_desc.call(attendee)),
          attendee.registration_type.id,
          attendee.base_price
        )
      end
    end
  end
  
  attr_reader :items, :invoice_type, :invoice_id
  
  def initialize(items, target)
    @items, @invoice_type, @invoice_id = items, target.class.to_s, target.id
  end
  
  def to_variables
    {}.tap do |vars|
      @items.each_with_index do |item, index|
        vars.merge!(item.to_variables(index+1))
      end
      vars['invoice'] = @invoice_id
      vars['custom'] = @invoice_type
    end
  end
  
  class PaypalItem
    attr_reader :name, :number, :amount, :quantity
    
    def initialize(name, number, amount, quantity = 1)
      @name, @number, @amount, @quantity = name, number, amount, quantity
    end
    
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
