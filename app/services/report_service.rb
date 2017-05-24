class ReportService
  include Singleton

  def create_burnup_structure(event)
    return BurnupPresenter.new([], []) if event.attendances.empty?
    registration_start_period = event.attendances.minimum(:created_at).to_date
    registration_end_period = event.start_date.to_date
    period_difference = registration_end_period - registration_start_period
    growth_rate = event.attendance_limit.to_f / period_difference.to_i
    mount_data_for_burnup_chart(event.attendances.confirmed, growth_rate, registration_end_period, registration_start_period)
  end

  private

  def mount_data_for_burnup_chart(attendances, growth_rate, end_period, start_period)
    burnup_actual = []
    burnup_ideal = []
    registration_sum = 0

    (start_period..end_period).each_with_index do |date, index|
      burnup_ideal << [date.to_time.to_i * 1000, growth_rate * index]
      registrations_in_day = attendances.where('created_at BETWEEN :start AND :end', start: date.beginning_of_day, end: date.end_of_day).count
      registration_sum += registrations_in_day
      burnup_actual << [date.to_time.to_i * 1000, registration_sum] if date <= Time.zone.today
    end
    BurnupPresenter.new(burnup_ideal, burnup_actual)
  end
end
