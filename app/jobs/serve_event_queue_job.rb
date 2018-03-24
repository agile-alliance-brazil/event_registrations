# frozen_string_literal: true

class ServeEventQueueJob < ApplicationJob
  queue_as :default

  def perform
    Event.active_for(Time.zone.today).each do |event|
      QueueService.serve_the_queue(event)
    end
  end
end
