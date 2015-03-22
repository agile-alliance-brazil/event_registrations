module Concerns
  module Registrable
    extend ActiveSupport::Concern

    included do
      belongs_to :registration_type
      belongs_to :registration_period
      belongs_to :registration_group

      validates_presence_of :registration_type_id, :registration_date, :user_id, :event_id

      scope :for_registration_type, ->(t) { where(registration_type_id: t.id) }
      scope :without_registration_type, ->(t) { where("#{table_name}.registration_type_id != (?)", t.id) }
    end

    def registration_period
      period = event.registration_periods.for(self.registration_date).first
      if period.super_early_bird? && !entitled_super_early_bird?
        period = event.registration_periods.for(period.end_at + 1.day).first
      end
      period
    end

    def registration_fee(overriden_registration_type = nil)
      registration_period.price_for_registration_type(overriden_registration_type || registration_type)
    end
  end
end