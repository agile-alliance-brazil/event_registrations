class CheckPagseguroInvoicesJob < ApplicationJob
  def perform
    event_active_for = Event.active_for(Time.zone.today)

    event_active_for.each do |event|
      Rails.logger.info("Checking payments for #{event.name}")
      min_date = event.attendances.pending.minimum(:registration_date)
      max_date = [event.attendances.pending.maximum(:registration_date), 12.hours.ago].min

      response = HTTParty.get("https://ws.pagseguro.uol.com.br/v2/transactions?email=#{Figaro.env.pag_seguro_email}&token=#{Figaro.env.pag_seguro_token}&initialDate=#{min_date.iso8601}&finalDate=#{max_date.iso8601}",
                              headers: { 'Content-Type' => 'application/json' })

      response_hash = Hash.from_xml(response.read_body)

      response_hash['transactionSearchResult']['transactions'].each do |transation|
        Rails.logger.info("code,reference,status,grossAmount,date")
        transation.second.each do |invoice_params|
          Rails.logger.info("#{invoice_params['code']},#{invoice_params['reference']},#{invoice_params['status']},#{invoice_params['grossAmount']},#{invoice_params['date']}")

          if invoice_params['reference'].present?
            attendance = Attendance.find_by(id: invoice_params['reference'])

            invoice = Invoice.where(attendance: attendance, transaction_id: invoice_params['code']).first_or_create
            invoice.update(settle_amount: invoice_params['grossAmount'], status: invoice_params['status'].to_i, invoice_date: invoice_params['date'])
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
      end
    end
  end
end
