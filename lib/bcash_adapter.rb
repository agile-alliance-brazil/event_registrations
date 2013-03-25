# encoding: UTF-8
require 'payment_gateway_adapter'

class BcashAdapter < PaymentGatewayAdapter
  def self.from_attendance(attendance)
    items = PaymentGatewayAdapter.from_attendance(attendance, BcashItem)
    self.new(items, attendance)
  end

  def add_variables(vars)
    vars['id_pedido'] = @invoice.id
    vars['frete']     = 0
    vars['email']     = @invoice.email
    vars['nome']      = @invoice.full_name
    vars['cpf']       = @invoice.cpf
    vars['sexo']      = @invoice.gender
    vars['telefone']  = @invoice.phone
    vars['endereco']  = @invoice.address
    vars['bairro']    = @invoice.neighbourhood
    vars['cidade']    = @invoice.city
    vars['estado']    = @invoice.state
    vars['cep']       = @invoice.zipcode
  end

  class BcashItem < Item
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
