class RegistrationPrice < ActiveRecord::Base
  belongs_to :registration_period
  belongs_to :registration_quota

  scope :for, ->(period) { where('registration_period_id = ?', period.id) }
end
