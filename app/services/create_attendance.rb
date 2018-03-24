# frozen_string_literal: true

class CreateAttendance
  def self.run_for(create_params)
    attributes = create_params.new_attributes
    @attendance = Attendance.new attributes
    @event = create_params.event
    @params = create_params.request_params
    find_attendance = @event.attendances.find_by(email: attributes[:email], status: %i[pending accepted paid confirmed])

    if find_attendance.present?
      @attendance.errors.add(:email, I18n.t('flash.attendance.create.already_existent'))
    else
      create_new_attendance(attributes, create_params)
    end

    @attendance
  end

  def self.create_new_attendance(attributes, create_params)
    @attendance = Attendance.new(attributes)
    @attendance.status = :waiting if @event.full? || @event.attendances_in_the_queue?

    @attendance = PerformGroupCheck.run(@attendance, @params['registration_token'])
    put_band
    @attendance.registration_value = @event.registration_price_for(@attendance, create_params.payment_type_params)
    invoice = Invoice.from_attendance(@attendance, create_params.payment_type_params)
    @attendance.payment_type = invoice.payment_type
    @attendance.invoices << invoice unless @attendance.invoices.include? invoice
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
      EmailNotifications.registration_pending(@attendance).deliver_now
    elsif @attendance.waiting?
      EmailNotifications.registration_waiting(@attendance).deliver_now
    end
  end
end
