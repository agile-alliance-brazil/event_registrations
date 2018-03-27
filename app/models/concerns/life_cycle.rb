# frozen_string_literal: true

module Concerns
  module LifeCycle
    extend ActiveSupport::Concern
    # rubocop:disable Metrics/BlockLength
    included do
      scope :pending, -> { where(status: :pending) }
      scope :accepted, -> { where(status: :accepted) }
      scope :cancelled, -> { where(status: :cancelled) }
      scope :paid, -> { where(status: :paid) }
      scope :confirmed, -> { where(status: :confirmed) }
      scope :committed_to, -> { where(status: %i[paid confirmed showed_in]) }
      scope :active, -> { where('status NOT IN (?)', %i[cancelled no_show waiting]) }
      scope :not_cancelled, -> { where('status <> ?', :cancelled) }
      scope :waiting, -> { where(status: :waiting) }
      scope :showed_in, -> { where(status: :showed_in) }

      state_machine :status, initial: :pending do
        after_transition on: %i[cancel mark_no_show], do: :cancel_invoice!
        after_transition on: :recover, do: :recover_invoice!
        after_transition on: :pay, do: %i[check_confirmation pay_invoice!]
        after_transition on: :confirm, do: :pay_invoice!
        after_transition on: :dequeue, do: :dequeue_attendance
        after_transition any => any, do: :update_last_status_change_date

        event(:accept) { transition pending: :accepted }
        event(:confirm) { transition %i[pending accepted paid] => :confirmed }
        event(:pay) { transition %i[pending accepted] => :paid }
        event(:cancel) { transition %i[waiting pending accepted paid confirmed] => :cancelled }
        event(:recover) { transition cancelled: :pending }
        event(:mark_no_show) { transition %i[pending accepted] => :no_show }
        event(:mark_show) { transition %i[paid confirmed] => :showed_in }
        event(:dequeue) { transition waiting: :pending }
        state(:confirmed) { validates :payment_agreement, acceptance: true }

        after_transition any => :confirmed do |attendance|
          try_user_notify(action: :registration_confirmed, attendance: attendance) do
            EmailNotifications.registration_confirmed(attendance).deliver_now
          end
        end

        after_transition pending: :accepted do |attendance|
          if attendance.free?
            attendance.confirm
          else
            try_user_notify(action: :registration_group_accepted, attendance: attendance) do
              EmailNotifications.registration_group_accepted(attendance).deliver_now
            end
          end
        end

        after_transition cancelled: :pending do |attendance|
          attendance.invoices.order(:created_at).last&.recover_it!
        end

        def try_user_notify(params)
          yield
        rescue StandardError => ex
          Airbrake.notify(ex.message, params)
        ensure
          Rails.logger.flush
        end
      end
    end
    # rubocop:enable Metrics/BlockLength

    def cancellable?
      waiting? || pending? || accepted? || paid? || confirmed?
    end

    def transferrable?
      paid? || confirmed?
    end

    def confirmable?
      paid? || pending? || accepted?
    end

    def recoverable?
      cancelled?
    end

    def payable?
      pending? || accepted?
    end

    private

    def check_confirmation
      confirm unless grouped? && registration_group.floor?
    end

    def cancel_invoice!
      change_invoice_status(user.invoices.order(created_at: :asc).last, :cancel_it!)
    end

    def recover_invoice!
      self.advised = false
      self.advised_at = nil
      change_invoice_status(user.invoices.where(status: 'cancelled').last, :recover_it!)
    end

    def pay_invoice!
      change_invoice_status(user.invoices.active.last, :pay_it!)
    end

    def change_invoice_status(invoice, method)
      return if invoice.blank?
      invoice.send(method)
      invoice.save!
    end

    def dequeue_attendance
      self.queue_time = ((Time.zone.now - created_at) / 1.hour).round
      EmailNotifications.registration_dequeued(self).deliver_now
    end

    def update_last_status_change_date
      self.last_status_change_date = Time.zone.now
      save
    end
  end
end
