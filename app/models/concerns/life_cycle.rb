module Concerns
  module LifeCycle
    extend ActiveSupport::Concern

    included do
      scope :pending, -> { where(status: :pending) }
      scope :pending_accepted, -> { where("status IN ('pending', 'accepted')") }
      scope :accepted, -> { where(status: :accepted) }
      scope :cancelled, -> { where(status: :cancelled) }
      scope :paid, -> { where(status: %i(paid confirmed)) }

      state_machine :status, initial: :pending do
        after_transition on: %i(cancel mark_no_show), do: :cancel_invoice!
        after_transition on: :recover, do: :recover_invoice!
        after_transition on: :pay, do: %i(check_confirmation pay_invoice!)

        event :accept do
          transition %i(pending) => :accepted
        end

        event :confirm do
          transition %i(pending accepted paid) => :confirmed
        end

        event :pay do
          transition %i(pending accepted) => :paid
        end

        event :cancel do
          transition %i(pending accepted paid confirmed) => :cancelled
        end

        event :recover do
          transition %i(cancelled) => :pending
        end

        event :mark_no_show do
          transition %i(pending accepted) => :no_show
        end

        state :confirmed do
          validates_acceptance_of :payment_agreement
        end

        after_transition any => :confirmed do |attendance|
          try_user_notify do
            EmailNotifications.registration_confirmed(attendance).deliver_now
          end
        end

        after_transition any => :accepted do |attendance|
          try_user_notify do
            EmailNotifications.registration_group_accepted(attendance).deliver_now
          end
        end

        def try_user_notify
          yield
        rescue => ex
          Airbrake.notify(ex)
        ensure
          Rails.logger.flush
        end
      end
    end

    def cancellable?
      pending? || accepted? || paid? || confirmed?
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
      self.confirm unless grouped? && registration_group.floor?
    end

    def cancel_invoice!
      invoice = user.invoices.individual.where(status: 'pending').last
      return unless invoice.present?
      invoice.cancel_it
      invoice.save!
    end

    def recover_invoice!
      invoice = user.invoices.individual.where(status: 'cancelled').last
      return unless invoice.present?
      invoice.recover_it
      invoice.save!
    end

    def pay_invoice!
      invoice = user.invoices.individual.active.last
      return unless invoice.present?
      invoice.amount = self.registration_value
      invoice.pay_it
      invoice.save!
    end
  end
end
