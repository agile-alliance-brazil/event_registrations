# frozen_string_literal: true

class AttendanceRepository
  include Singleton

  def search_for_list(event, text, statuses)
    statuses_keys = statuses.map { |status| Attendance.statuses[status] }
    event.attendances.where(status: statuses_keys).where('((first_name LIKE :first_name OR last_name LIKE :last_name OR organization LIKE :organization OR email LIKE :email OR attendances.id = :attendance_id))', first_name: "%#{text}%", last_name: "%#{text}%", organization: "%#{text}%", email: "%#{text}%", attendance_id: text.to_s).order(updated_at: :desc)
  end

  def for_cancelation_warning(event)
    older_than(event.days_to_charge.days.ago)
      .where('event_id = ? AND (((attendances.status = 1 AND attendances.registration_group_id IS NULL) OR (attendances.status = 2)) AND advised = ?)', event.id, false)
      .joins(:invoices).where('invoices.payment_type = ?', Invoice.payment_types[:gateway])
  end

  def for_cancelation(event)
    Attendance.where('event_id = ? AND (attendances.status IN (1, 2) AND advised = true AND due_date < current_timestamp)', event.id)
              .joins(:invoices).where('invoices.payment_type = ?', Invoice.payment_types[:gateway])
  end

  def attendances_for(event, user_param)
    Attendance.where('event_id = ? AND user_id = ?', event.id, user_param.id).order(created_at: :asc)
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
