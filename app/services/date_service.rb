# frozen_string_literal: true

class DateService
  include Singleton

  def skip_weekends(date, increment)
    date += increment.round.days
    date += 1.day while (date.wday % 7).zero? || (date.wday % 7 == 6)
    date
  end
end
