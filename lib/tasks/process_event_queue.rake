namespace :registration do
  desc 'Process the event queue'
  task process_queue: :environment do
    ServeEventQueueJob.perform_now
  end
end
