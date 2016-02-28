class CreateAttendance
  def self.run_for(create_params)
    attributes = create_params.new_attributes
    @attendance = Attendance.new attributes
    @event = create_params.event
    @params = create_params.request_params
    find_attendance = @event.attendances.find_by(email: attributes[:email], status: %i(pending accepted paid confirmed))
    if find_attendance.present?
      @attendance.errors.add(:email, I18n.t('flash.attendance.create.already_existent'))
    else
      @attendance = Attendance.new(attributes)
      @attendance.status = :waiting unless @event.can_add_attendance?
      @attendance = PerformGroupCheck.run(@attendance, @params['registration_token'])
      put_band
      @attendance.registration_value = @event.registration_price_for(@attendance, create_params.payment_type_params)
      invoice = Invoice.from_attendance(@attendance, create_params.payment_type_params)
      @attendance.payment_type = invoice.payment_type
      @attendance.invoices << invoice unless @attendance.invoices.include? invoice
      save_attendance!
    end

    @attendance
  end

  def self.put_band
    @attendance.registration_period = @event.period_for
    quota = @event.find_quota
    @attendance.registration_quota = quota.first if quota.present?
  end

  def self.save_attendance!
    if @attendance.save
      begin
        EmailNotifications.registration_pending(@attendance).deliver_now
      rescue => ex
        NotifyAirbrake.run_for(ex, action: :registration_pending, attendance: { event: @event, email: @attendance.email })
      end
    end
  end
end
