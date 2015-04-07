class Invoice < ActiveRecord::Base

  belongs_to :attendance
  belongs_to :registration_group

  def self.from_attendance(attendance)
    invoice = Invoice.new
    attendance = Attendance.find_by_id(attendance.id)
    invoice.attendance = attendance
    # vars['frete']     = 0
    # vars['email']     = @invoice.email
    # vars['nome']      = @invoice.full_name
    # vars['cpf']       = @invoice.cpf
    # vars['sexo']      = @invoice.gender
    # vars['telefone']  = @invoice.phone
    # vars['endereco']  = @invoice.address
    # vars['bairro']    = @invoice.neighbourhood
    # vars['cidade']    = @invoice.city
    # vars['estado']    = @invoice.state
    # vars['cep']       = @invoice.zipcode

    return invoice
  end
end