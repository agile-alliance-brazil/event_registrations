class QueueService
  def self.serve_the_queue(event)
    return if event.full?
    event_queue = AttendanceRepository.instance.event_queue(event).to_a

    until event.full? || event_queue.empty?
      attendance = event_queue.shift
      attendance.dequeue
    end
  end
end
