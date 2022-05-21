# frozen_string_literal: true

class CheckPagseguroInvoicesJob < ApplicationJob
  def perform
    event_active_for = Event.active_for(Time.zone.today)

    event_active_for.each do |event|
      Rails.logger.info("Checking payments for #{event.name}")
      attendances_to_check = event.attendances.where('status = 1 OR status = 2')
      min_date = attendances_to_check.minimum(:registration_date).localtime.beginning_of_day
      max_date = [attendances_to_check.maximum(:registration_date).localtime, 2.hours.ago].min

      response = HTTParty.get("#{Figaro.env.pag_seguro_url}/transactions?email=#{Figaro.env.pag_seguro_email}&token=#{Figaro.env.pag_seguro_token}&initialDate=#{min_date.iso8601}&finalDate=#{max_date.iso8601}",
                              headers: { 'Content-Type' => 'application/json' })

      Rails.logger.info("Checking payments response code #{response.code}")
      Rails.logger.info("Checking payments response body #{response.read_body}")
      response_hash = Hash.from_xml(response.read_body)

      PagseguroAdapter.instance.read_pag_seguro_body(response_hash['transactionSearchResult']['transactions'])
    end
  end
end
