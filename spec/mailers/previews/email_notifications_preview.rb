# frozen_string_literal: true

class EmailNotificationsPreview < ActionMailer::Preview
  def registration_dequeued
    attendance = Attendance.last
    EmailNotificationsMailer.with(attendance).registration_dequeued(attendance)
  end

  def registration_pending
    attendance = Attendance.last
    EmailNotificationsMailer.with(attendance).registration_pending(attendance)
  end

  def registration_group_accepted
    attendance = Attendance.last
    attendance.update(registration_group: RegistrationGroup.last)
    EmailNotificationsMailer.with(attendance).registration_group_accepted(attendance)
  end

  def registration_waiting
    attendance = Attendance.last
    EmailNotificationsMailer.with(attendance).registration_waiting(attendance)
  end

  def registration_confirmed
    attendance = Attendance.last
    EmailNotificationsMailer.with(attendance).registration_confirmed(attendance)
  end

  def welcome_attendance_remote_event
    attendance = Attendance.last
    EmailNotificationsMailer.with(attendance).welcome_attendance_remote_event(attendance)
  end

  def welcome_attendance
    attendance = Attendance.last
    EmailNotificationsMailer.with(attendance).welcome_attendance(attendance)
  end

  def cancelling_registration
    attendance = Attendance.last
    EmailNotificationsMailer.with(attendance).cancelling_registration(attendance)
  end

  def cancelling_registration_warning
    attendance = Attendance.last
    attendance.update(due_date: 7.days.from_now)
    EmailNotificationsMailer.with(attendance).cancelling_registration_warning(attendance)
  end
end
