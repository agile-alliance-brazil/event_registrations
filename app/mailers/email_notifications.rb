# encoding: UTF-8
class EmailNotifications < ActionMailer::Base
  def mail_with_default(params)
    mail_without_default default_mail_preferences.merge(params)
  end
  alias_method_chain :mail, :default

  def registration_pending(attendance, sent_at = Time.now)
    @attendance = attendance
    I18n.locale = @attendance.country == 'BR' ? :pt : :en
    mail subject: "[#{host}] #{I18n.t('email.registration_pending.subject', event_name: @attendance.event.name)}",
         cc: event_organizer, date: sent_at
  end

  def registration_confirmed(attendance, sent_at = Time.now)
    @attendance = attendance
    I18n.locale = @attendance.country == 'BR' ? :pt : :en
    mail subject: "[#{host}] #{I18n.t('email.registration_confirmed.subject', event_name: @attendance.event.name)}",
      date: sent_at
  end

  def cancelling_registration(attendance, sent_at = Time.now)
    @attendance = attendance
    I18n.locale = @attendance.country == 'BR' ? :pt : :en
    mail subject: "[#{host}] #{I18n.t('email.cancelling_registration.subject', event_name: @attendance.event.name, attendance_id: @attendance.id)}",
      date: sent_at
  end

  def cancelling_registration_warning(attendance, sent_at = Time.now)
    @attendance = attendance
    I18n.locale = @attendance.country == 'BR' ? :pt : :en
    mail subject: "[#{host}] #{I18n.t('email.cancelling_registration_warning.subject', event_name: @attendance.event.name, attendance_id: @attendance.id)}",
      date: sent_at
  end

  private
  def default_mail_preferences
    {
      to: "\"#{@attendance.full_name}\" <#{@attendance.email}>",
      from: "\"#{@attendance.event.name}\" <#{from_address}>",
      reply_to: "\"#{@attendance.event.name}\" <#{from_address}>"
    }
  end

  def from_address
    AppConfig[:ses][:from]
  end

  def host
    AppConfig[:host]
  end
  
  def event_organizer
    [
      "\"#{AppConfig[:organizer][:name]}\" <#{AppConfig[:organizer][:email]}>",
      "\"#{AppConfig[:organizer][:cced]}\" <#{AppConfig[:organizer][:cced_email]}>"
    ]
  end
end
