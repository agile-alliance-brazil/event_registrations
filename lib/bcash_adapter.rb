# encoding: UTF-8
class BcashAdapter
  class << self
    def from_attendance(attendance)
      registration_desc = lambda do |attendance|
        "#{I18n.t(attendance.registration_type.title)} Registration" # TODO i18n
      end
      items = create_items(attendance, registration_desc)
      self.new(items, attendance)
    end

    private
    def create_items(attendance, registration_desc)
      [].tap do |items|
        items << BcashItem.new(
          CGI.escapeHTML(registration_desc.call(attendance)),
          attendance.registration_type.id,
          attendance.base_price
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
      vars['id_pedido'] = @invoice.id
      vars['frete'] = 0
      vars['email'] = @invoice.user.email
      vars['nome']  = @invoice.user.full_name
      vars['cpf']   = @invoice.user.cpf
      vars['sexo']  = @invoice.user.gender
      vars['telefone'] = @invoice.user.phone
      vars['endereco'] = @invoice.user.address
      vars['bairro'] = @invoice.user.neighbourhood
      vars['cidade'] = @invoice.user.city
      vars['estado'] = @invoice.user.state
      vars['cep'] = @invoice.user.zipcode
    end
  end

  class BcashItem
    attr_reader :name, :number, :amount, :quantity

    def initialize(name, number, amount, quantity = 1)
      @name, @number, @amount, @quantity = name, number, amount, quantity
    end

    def to_variables(index)
      {
        "produto_valor_#{index}" => amount,
        "produto_descricao_#{index}" => name,
        "produto_codigo_#{index}" => number,
        "produto_qtde_#{index}" => quantity
      }
    end
  end
end
