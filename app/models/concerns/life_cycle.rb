module Concerns
  module LifeCycle
    extend ActiveSupport::Concern

    included do
      scope :pending, -> { where(status: :pending) }
      scope :accepted, -> { where(status: :accepted) }
      scope :cancelled, -> { where(status: :cancelled) }
      scope :paid, -> { where(status: [:paid, :confirmed]) }

      state_machine :status, initial: :pending do
        after_transition on: :cancel, do: :cancel_invoice!

        event :accept do
          transition [:pending] => :accepted
        end

        event :confirm do
          transition [:pending, :paid] => :confirmed
        end

        event :pay do
          transition [:pending, :confirmed, :accepted] => :paid
        end

        event :cancel do
          transition [:pending, :accepted] => :cancelled
        end

        state :confirmed do
          validates_acceptance_of :payment_agreement
        end

        after_transition any => :confirmed do |attendance|
          begin
            EmailNotifications.registration_confirmed(attendance).deliver_now
          rescue => ex
            Airbrake.notify(ex)
          end
        end

        after_transition any => :accepted do |attendance|
          begin
            EmailNotifications.registration_group_accepted(attendance).deliver_now
          rescue => ex
            Airbrake.notify(ex)
          end
        end
      end
    end

    def cancellable?
      pending?
    end
  end
end
