# frozen_string_literal: true

class EmailNotificationsMailer < ApplicationMailer
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

  def registration_dequeued(attendance, sent_at = Time.zone.now)
    mail_attendance(attendance, sent_at, 'email.registration_dequeued.subject')
  end

  def welcome_attendance(attendance, sent_at = Time.zone.now)
    mail_attendance(attendance, sent_at, 'email.welcome_attendance.subject')
  end

  private

  def mail_attendance(attendance, sent_at, title)
    @attendance = attendance
    @event = attendance.event

    subject = I18n.t(title, event_name: attendance.event_name, attendance_id: attendance.id).to_s
    Rails.logger.info("[EmailNotificationsMailer:mail_attendance] { mail informations: { subject: #{subject} } }")

    from_email = @event.main_email_contact || 'inscricoes@agilebrazil.com'
    headers = { from: from_email, to: attendance.email, subject: subject, date: sent_at }
    headers[:cc] = @attendance.event.main_email_contact if @attendance.event.main_email_contact
    mail(headers)
  end
end
