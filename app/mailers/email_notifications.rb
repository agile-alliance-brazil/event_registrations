# encoding: UTF-8
class EmailNotifications < ActionMailer::Base
  def registration_pending(attendee, sent_at = Time.now)
    @attendee = attendee
    I18n.locale = @attendee.country == 'BR' ? :pt : :en
    mail :subject => "[#{host}] #{I18n.t('email.registration_pending.subject', :event_name => current_event.name)}",
         :to      => "\"#{attendee.full_name}\" <#{attendee.email}>",
         :cc       => event_organizer,
         :from     => "\"#{current_event.name}\" <#{from_address}>",
         :reply_to => "\"#{current_event.name}\" <#{from_address}>",
         :date => sent_at
  end

  def registration_confirmed(attendee, sent_at = Time.now)
    @attendee, @group = attendee, attendee.registration_group
    I18n.locale = @attendee.country == 'BR' ? :pt : :en
    mail :subject => "[#{host}] #{I18n.t('email.registration_confirmed.subject', :event_name => current_event.name)}",
         :to      => "\"#{attendee.full_name}\" <#{attendee.email}>",
         :cc       => (@group.present? ? "\"#{@group.contact_name}\" <#{@group.contact_email}>" : []),
         :from     => "\"#{current_event.name}\" <#{from_address}>",
         :reply_to => "\"#{current_event.name}\" <#{from_address}>",
         :date => sent_at
  end

  def registration_group_attendee(attendee, group, sent_at = Time.now)
    @attendee, @group = attendee, group
    I18n.locale = @attendee.country == 'BR' ? :pt : :en
    mail :subject => "[#{host}] #{I18n.t('email.registration_group_pending.subject', :event_name => current_event.name)}",
         :to      => "\"#{attendee.full_name}\" <#{attendee.email}>",
         :cc       => "\"#{@group.contact_name}\" <#{@group.contact_email}>",
         :from     => "\"#{current_event.name}\" <#{from_address}>",
         :reply_to => "\"#{current_event.name}\" <#{from_address}>",
         :date => sent_at
  end

  def registration_group_pending(group, sent_at = Time.now)
    @group = group
    I18n.locale = @group.country == 'BR' ? :pt : :en
    @event_name = current_event.name
    mail :subject => "[#{host}] #{I18n.t('email.registration_group_pending.subject', :event_name => current_event.name)}",
         :to      => "\"#{@group.contact_name}\" <#{@group.contact_email}>",
         :cc       => event_organizer,
         :from     => "\"#{@event_name}\" <#{from_address}>",
         :reply_to => "\"#{@event_name}\" <#{from_address}>",
         :date => sent_at
  end

  def registration_group_confirmed(registration_group, sent_at = Time.now)
    @registration_group = registration_group
    I18n.locale = @registration_group.country == 'BR' ? :pt : :en
    @event_name = current_event.name
    mail :subject  => "[#{host}] #{I18n.t('email.registration_group_confirmed.subject', :event_name => current_event.name)}",
         :to       => "\"#{registration_group.contact_name}\" <#{registration_group.contact_email}>",
         :cc       => event_organizer,
         :from     => "\"#{current_event.name}\" <#{from_address}>",
         :reply_to => "\"#{current_event.name}\" <#{from_address}>",
         :date => sent_at
  end

  def registration_reminder(attendee, sent_at = Time.now)
    @attendee = attendee
    I18n.locale = @attendee.default_locale
    @event_name = current_event.name
    mail :subject => "[#{host}] #{I18n.t('email.registration_reminder.subject', :event_name => current_event.name)}",
         :to      => "\"#{attendee.full_name}\" <#{attendee.email}>",
         :cc       => event_organizer,
         :from     => "\"#{current_event.name}\" <#{from_address}>",
         :reply_to => "\"#{current_event.name}\" <#{from_address}>",
         :date => sent_at
  end

  private
  def from_address
    ActionMailer::Base.smtp_settings[:user_name]
  end

  def host
    ActionMailer::Base.default_url_options[:host]
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
