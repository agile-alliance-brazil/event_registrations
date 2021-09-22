# frozen_string_literal: true

class AttendanceRepository
  include Singleton

  def search_for_list(event, text, user_disability, statuses)
    statuses_keys = statuses.map { |status| Attendance.statuses[status] }
    attendances = event.attendances.joins(:user).where(status: statuses_keys).where('((users.first_name ILIKE :search_param OR users.last_name ILIKE :search_param OR organization ILIKE :search_param OR users.email ILIKE :search_param))', search_param: "%#{text&.downcase}%").order(updated_at: :desc)
    return attendances if user_disability.blank?

    attendances.where(users: { disability: user_disability })
  end

  def for_cancelation_warning(event)
    older_than(event.days_to_charge.days.ago).where('event_id = :event_id AND (((attendances.status = 1 AND attendances.registration_group_id IS NULL) OR (attendances.status = 2)) AND advised = false AND payment_type = 1)', event_id: event.id)
  end

  def for_cancelation(event)
    Attendance.where('event_id = ? AND (attendances.status IN (1, 2) AND advised = true AND due_date < current_timestamp AND payment_type = 1)', event.id)
  end

  def attendances_for(event, user_param)
    Attendance.where('event_id = :event_id AND user_id = :user_id', event_id: event.id, user_id: user_param.id).order(created_at: :asc)
  end

  def for_event(event)
    Attendance.where(event_id: event.id)
  end

  def event_queue(event)
    Attendance.where(event_id: event.id, status: :waiting).order(created_at: :asc)
  end

  private

  def older_than(date = Time.zone.now)
    Attendance.where('last_status_change_date <= (?)', date)
  end
end
