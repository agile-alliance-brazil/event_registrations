# frozen_string_literal: true

class CheckPagseguroInvoicesJob < ApplicationJob
  def perform
    event_active_for = Event.active_for(Time.zone.today)

    event_active_for.each do |event|
      Rails.logger.info("Checking payments for #{event.name}")
      min_date = event.attendances.pending.minimum(:registration_date)
      max_date = [event.attendances.pending.maximum(:registration_date), 12.hours.ago].min

      response = HTTParty.get("#{Figaro.env.pag_seguro_url}/transactions?email=#{Figaro.env.pag_seguro_email}&token=#{Figaro.env.pag_seguro_token}&initialDate=#{min_date.iso8601}&finalDate=#{max_date.iso8601}",
                              headers: { 'Content-Type' => 'application/json' })

      response_hash = Hash.from_xml(response.read_body)

      PagseguroAdapter.instance.read_pag_seguro_body(response_hash['transactionSearchResult']['transactions'])
    end
  end
end
