class AttendanceRepository
  include Singleton

  def search_for_list(event, text, status)
    Attendance.where('event_id = ? AND ((first_name LIKE ? OR last_name LIKE ? OR organization LIKE ? OR email LIKE ? OR id = ?) AND attendances.status IN (?))',
                     event.id, "%#{text}%", "%#{text}%", "%#{text}%", "%#{text}%", text.to_s, status).order(created_at: :desc)
  end

  def for_cancelation_warning(event)
    older_than(event.days_to_charge.days.ago)
      .where("event_id = ? AND (((attendances.status = 'pending' AND attendances.registration_group_id IS NULL) OR (attendances.status = 'accepted')) AND advised = ?)", event.id, false)
      .joins(:invoices).where('invoices.payment_type = ?', Invoice::GATEWAY)
  end

  def for_cancelation(event)
    Attendance.where("event_id = ? AND (attendances.status IN ('pending', 'accepted') AND advised = ? AND advised_at <= (?))", event.id, true, event.days_to_charge.days.ago)
              .joins(:invoices).where('invoices.payment_type = ?', Invoice::GATEWAY)
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
