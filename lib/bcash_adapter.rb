# encoding: UTF-8
require 'payment_gateway_adapter'

class BcashAdapter < PaymentGatewayAdapter
  def self.from_invoice(invoice)
    items = PaymentGatewayAdapter.from_invoice(invoice, BcashItem)
    self.new(items, invoice)
  end

  def add_variables(vars)
    vars['id_pedido'] = @invoice.id
    vars['frete']     = 0
    vars['email']     = @invoice.email
    vars['nome']      = @invoice.name
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
