module Concerns
  module LifeCycle
    extend ActiveSupport::Concern
    included do
      scope :pending, -> { where("attendances.status IN ('pending', 'accepted')") }
      scope :accepted, -> { where(status: :accepted) }
      scope :cancelled, -> { where(status: :cancelled) }
      scope :paid, -> { where(status: %i(paid confirmed)) }
      scope :active, -> { where('status NOT IN (?)', %i(cancelled no_show waiting)) }
      scope :waiting, -> { where(status: :waiting) }

      state_machine :status, initial: :pending do
        after_transition on: %i(cancel mark_no_show), do: :cancel_invoice!
        after_transition on: :recover, do: :recover_invoice!
        after_transition on: :pay, do: %i(check_confirmation pay_invoice!)
        after_transition on: :confirm, do: :pay_invoice!
        after_transition on: :dequeue, do: :dequeue_attendance

        event :accept do
          transition pending: :accepted
        end

        event :confirm do
          transition %i(pending accepted paid) => :confirmed
        end

        event :pay do
          transition %i(pending accepted) => :paid
        end

        event :cancel do
          transition %i(waiting pending accepted paid confirmed) => :cancelled
        end

        event :recover do
          transition cancelled: :pending
        end

        event :mark_no_show do
          transition %i(pending accepted) => :no_show
        end

        event :dequeue do
          transition waiting: :pending
        end

        state :confirmed do
          validates :payment_agreement, acceptance: true
        end

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

        def try_user_notify(params)
          yield
        rescue => ex
          Airbrake.notify(ex.message, params)
        ensure
          Rails.logger.flush
        end
      end
    end

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
      change_invoice_status(user.invoices.where(status: 'pending').last, :cancel_it)
    end

    def recover_invoice!
      change_invoice_status(user.invoices.where(status: 'cancelled').last, :recover_it)
    end

    def pay_invoice!
      change_invoice_status(user.invoices.active.last, :pay_it)
    end

    def change_invoice_status(invoice, method)
      return unless invoice.present?
      invoice.send(method)
      invoice.save!
    end

    def dequeue_attendance
      self.queue_time = ((Time.zone.now - created_at) / 1.hour).round
      self.created_at = Time.zone.now
      EmailNotifications.registration_dequeued(self).deliver_now
    end
  end
end
