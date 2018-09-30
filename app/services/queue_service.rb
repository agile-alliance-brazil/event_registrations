# frozen_string_literal: true

class QueueService
  def self.serve_the_queue(event)
    return if event.full?

    event_queue = AttendanceRepository.instance.event_queue(event).to_a

    until event.full? || event_queue.empty?
      attendance = event_queue.shift
      attendance.pending!
      attendance.update(queue_time: ((Time.zone.now - attendance.created_at) / 1.hour).round)
      EmailNotifications.registration_dequeued(attendance).deliver_now if attendance.reload.pending?
    end
  end
end
