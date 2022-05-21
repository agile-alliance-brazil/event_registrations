# frozen_string_literal: true

namespace :invoices do
  desc 'Process the event queue'
  task process_pagseguro: :environment do
    CheckPagseguroInvoicesJob.perform_now
  end
end
