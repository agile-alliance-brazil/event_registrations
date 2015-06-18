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
    Rails.logger.info("[EmailNotifications:mail_attendance] { mail informations: { locale: #{I18n.locale}, host: #{host}, title: #{title}, attendance_id: #{attendance.id} } }")
    subject = "[#{host}] #{I18n.t(title, event_name: attendance.event.name, attendance_id: attendance.id)}"
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
      from: "\"#{@attendance.event.name}\" <#{from_address}>",
      reply_to: "\"#{@attendance.event.name}\" <#{from_address}>"
    }
  end

  def from_address
    APP_CONFIG[:ses][:from]
  end

  def host
    Rails.logger.info("[EmailNotifications:host] { mail informations: { #{APP_CONFIG[:host]} } }")
    APP_CONFIG[:host]
  end
  
  def event_organizer
    [
      "\"#{APP_CONFIG[:organizer][:name]}\" <#{APP_CONFIG[:organizer][:email]}>",
      "\"#{APP_CONFIG[:organizer][:cced]}\" <#{APP_CONFIG[:organizer][:cced_email]}>"
    ]
  end

  def log_mail_informations
  end
end
