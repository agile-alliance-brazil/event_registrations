# encoding: UTF-8
class EmailNotifications < ActionMailer::Base
  def registration_pending(attendance, sent_at = Time.now)
    @attendance = attendance
    @attendee = attendance.user
    I18n.locale = @attendee.country == 'BR' ? :pt : :en
    mail :subject => "[#{host}] #{I18n.t('email.registration_pending.subject', :event_name => current_event.name)}",
         :to      => "\"#{@attendee.full_name}\" <#{@attendee.email}>",
         :cc       => event_organizer,
         :from     => "\"#{current_event.name}\" <#{from_address}>",
         :reply_to => "\"#{current_event.name}\" <#{from_address}>",
         :date => sent_at
  end

  def registration_confirmed(attendance, sent_at = Time.now)
    @attendance = attendance
    @attendee = attendance.user
    I18n.locale = @attendee.country == 'BR' ? :pt : :en
    mail :subject => "[#{host}] #{I18n.t('email.registration_confirmed.subject', :event_name => current_event.name)}",
         :to      => "\"#{@attendee.full_name}\" <#{@attendee.email}>",
         :from     => "\"#{current_event.name}\" <#{from_address}>",
         :reply_to => "\"#{current_event.name}\" <#{from_address}>",
         :date => sent_at
  end

  private
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

  def current_event
    @current_event ||= Event.current
  end
end
