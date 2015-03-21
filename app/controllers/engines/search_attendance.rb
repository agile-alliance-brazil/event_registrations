module Engines
  module SearchAttendance
    def self.search(param, event)
      Attendance.for_event(event).
        active.where('first_name LIKE :query OR last_name LIKE :query OR organization LIKE :query OR email LIKE :query',
                     query: "%#{param}%")
    end
  end
end