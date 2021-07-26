# frozen_string_literal: true

class CreateAttendance
  def self.run_for(create_params)
    attributes = create_params.new_attributes
    @attendance = Attendance.new(attributes)
    @event = create_params.event
    @params = create_params.request_params
    create_new_attendance(attributes, create_params)
    @attendance
  end

  def self.create_new_attendance(attributes, create_params)
    @attendance = Attendance.new(attributes)
    @attendance.status = :waiting if @event.full? || @event.attendances_in_the_queue?

    @attendance = PerformGroupCheck.instance.run(@attendance, @params['registration_token'])
    put_band
    @attendance.registration_value = @event.registration_price_for(@attendance, create_params.payment_type_params)
    @attendance.payment_type = create_params.payment_type_params
    save_attendance!
  end

  def self.put_band
    @attendance.registration_period = @event.period_for
    quota = @event.find_quota
    @attendance.registration_quota = quota.first if quota.present?
  end

  def self.save_attendance!
    notify_attendance if @attendance.save
  end

  def self.notify_attendance
    if @attendance.pending?
      EmailNotificationsMailer.registration_pending(@attendance).deliver
      @attendance.event.slack_configurations.each do |slack_config|
        slack_notifier = Slack::Notifier.new(slack_config.room_webhook)
        Slack::SlackNotificationService.instance.notify_new_registration(slack_notifier, @attendance)
      end

    elsif @attendance.waiting?
      EmailNotificationsMailer.registration_waiting(@attendance).deliver
    end
  end
end
