# frozen_string_literal: true

class EmailNotificationsPreview < ActionMailer::Preview
  def registration_dequeued
    EmailNotificationsMailer.with(attendance).registration_dequeued(attendance)
  end

  def registration_pending
    EmailNotificationsMailer.with(attendance).registration_pending(attendance)
  end

  def registration_group_accepted
    attendance.update(registration_group: registration_group)
    EmailNotificationsMailer.with(attendance).registration_group_accepted(attendance)
  end

  def registration_waiting
    EmailNotificationsMailer.with(attendance).registration_waiting(attendance)
  end

  def registration_confirmed
    EmailNotificationsMailer.with(attendance).registration_confirmed(attendance)
  end

  def registration_paid
    EmailNotificationsMailer.with(attendance).registration_paid(attendance)
  end

  def welcome_attendance_remote_event
    EmailNotificationsMailer.with(attendance).welcome_attendance_remote_event(attendance)
  end

  def welcome_attendance
    EmailNotificationsMailer.with(attendance).welcome_attendance(attendance)
  end

  def cancelling_registration
    EmailNotificationsMailer.with(attendance).cancelling_registration(attendance)
  end

  def cancelling_registration_warning
    attendance.update(due_date: 7.days.from_now)
    EmailNotificationsMailer.with(attendance).cancelling_registration_warning(attendance)
  end

  private

  def attendance
    @attendance = (@attendance || Attendance.last || Fabricate(:attendance))
  end

  def registration_group
    @registration_group = (@registration_group || RegistrationGroup.last || Fabricate(:registration_group))
  end
end
