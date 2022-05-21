# frozen_string_literal: true

# == Schema Information
#
# Table name: invoices
#
#  attendance_id  :bigint(8)        indexed
#  created_at     :timestamptz      not null
#  id             :bigint(8)        not null, primary key, indexed
#  invoice_date   :datetime         not null
#  payer_email    :string(255)
#  payment_type   :integer          default("pag_seguro"), not null, indexed
#  settle_amount  :decimal(10, )    not null
#  status         :integer          default("waiting"), indexed
#  transaction_id :string(255)      not null
#  updated_at     :timestamptz      not null
#
# Indexes
#
#  idx_4539845_index_payment_notifications_on_attendance_id  (attendance_id)
#  index_invoices_on_payment_type                            (payment_type)
#  index_invoices_on_status                                  (status)
#  invoices_pkey                                             (id)
#
# Foreign Keys
#
#  fk_rails_2e64051bbf  (attendance_id => attendances.id) ON DELETE => cascade ON UPDATE => cascade
#

# 1: Aguardando Pagamento:o comprador iniciou a transação, mas até o momento o PagSeguro não recebeu nenhuma informação sobre o pagamento.
# 2: Em análise: o comprador optou por pagar com um cartão de crédito e o PagSeguro está analisando o risco da transação.
# 3: Paga:a transação foi paga pelo comprador e o PagSeguro já recebeu uma confirmação da instituição financeira responsável pelo processamento.
# 4: Disponível:a transação foi paga e chegou ao final de seu prazo de liberação sem ter sido retornada e sem que haja nenhuma disputa aberta.
# 5: Em disputa:o comprador, dentro do prazo de liberação da transação, abriu uma disputa.
# 6: Devolvida:o valor da transação foi devolvido para o comprador.
# 7: Cancelada:a transação foi cancelada sem ter sido finalizada.
##
class Invoice < ApplicationRecord
  enum status: { waiting: 1, analysis: 2, paid: 3, available: 4, financial_dispute: 5, value_returned: 6, cancelled: 7 }
  enum payment_type: { pag_seguro: 0 }

  belongs_to :attendance

  validates :payment_type, :settle_amount, :status, :transaction_id, presence: true

  def paid?
    (status == 'paid' || status == 'available') && (settle_amount >= attendance.registration_value)
  end
end
