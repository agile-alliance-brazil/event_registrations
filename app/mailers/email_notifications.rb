# encoding: UTF-8
class EmailNotifications < ActionMailer::Base
  def registration_pending(attendance, sent_at = Time.zone.now)
    mail_attendance(attendance, sent_at, 'email.registration_pending.subject')
  end

  def registration_group_accepted(attendance, sent_at = Time.zone.now)
    mail_attendance(attendance, sent_at, 'email.registration_accepted.subject')
  end

  def registration_confirmed(attendance, sent_at = Time.zone.now)
    mail_attendance(attendance, sent_at, 'email.registration_confirmed.subject')
  end

  def registration_waiting(attendance, sent_at = Time.zone.now)
    mail_attendance(attendance, sent_at, 'email.registration_waiting.subject')
  end

  def cancelling_registration(attendance, sent_at = Time.zone.now)
    mail_attendance(attendance, sent_at, 'email.cancelling_registration.subject')
  end

  def cancelling_registration_warning(attendance, sent_at = Time.zone.now)
    mail_attendance(attendance, sent_at, 'email.cancelling_registration_warning.subject')
  end

  private

  def mail_attendance(attendance, sent_at, title)
    @attendance = attendance
    I18n.locale = attendance.country == 'BR' ? :pt : :en
    subject = I18n.t(title, event_name: attendance.event_name, attendance_id: attendance.id).to_s
    Rails.logger.info("[EmailNotifications:mail_attendance] { mail informations: { subject: #{subject} } }")
    mail subject: subject, cc: event_organizer, date: sent_at
  end

  def mail_with_default(params)
    mail_without_default default_mail_preferences.merge(params)
  end
  alias_method_chain :mail, :default

  def default_mail_preferences
    {
      to: "\"#{@attendance.full_name}\" <#{@attendance.email}>",
      from: "\"#{@attendance.event_name}\" <#{from_address}>",
      reply_to: "\"#{@attendance.event_name}\" <#{from_address}>"
    }
  end

  def from_address
    APP_CONFIG[:ses][:from]
  end

  def event_organizer
    if @attendance.event.present? && @attendance.event.organizers.present?
      organizers = []
      @attendance.event.organizers.each do |organizer|
        organizers << "\"#{organizer.first_name}\" <#{organizer.email}>"
      end
    else
      organizers = ["\"#{APP_CONFIG[:organizer][:name]}\" <#{APP_CONFIG[:organizer][:email]}>"]
    end
    organizers
  end
end
