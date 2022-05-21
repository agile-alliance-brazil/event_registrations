# frozen_string_literal: true

class PagseguroAdapter
  include Singleton

  def read_pag_seguro_body(response_hash)
    response_hash.each do |transaction|
      Rails.logger.info('code,reference,status,grossAmount,date')
      transaction.second.each do |invoice_params|
        next if invoice_params.is_a?(Array) || invoice_params['reference'].blank?

        Rails.logger.info(invoice_params)
        Rails.logger.info("#{invoice_params['code']},#{invoice_params['reference']},#{invoice_params['status']},#{invoice_params['grossAmount']},#{invoice_params['date']}")

        attendance = Attendance.find_by(id: invoice_params['reference'])
        next if attendance.blank?

        invoice = Invoice.where(attendance: attendance, transaction_id: invoice_params['code']).first_or_create
        invoice.update(settle_amount: invoice_params['grossAmount'], status: invoice_params['status'].to_i, invoice_date: invoice_params['date'])
        process_valid_invoice(attendance, invoice, invoice_params)
      end
    end
  end

  private

  def process_valid_invoice(attendance, invoice, invoice_params)
    return unless attendance.pending? || attendance.accepted?

    if invoice.valid?
      Rails.logger.info("Invoice #{invoice_params['reference']} processed.")

      if invoice.paid?
        Rails.logger.info("Attendance #{attendance.id} paid.")
        attendance.paid!
        EmailNotificationsMailer.registration_paid(attendance).deliver
      end
    else
      Rails.logger.info("Failed to process Invoice #{invoice_params['reference']}. Errors: #{invoice.errors.full_messages}")
    end
  end
end
