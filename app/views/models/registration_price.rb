# == Schema Information
#
# Table name: registration_prices
#
#  id                     :integer          not null, primary key
#  registration_type_id   :integer
#  registration_period_id :integer
#  value                  :decimal(, )
#  created_at             :datetime
#  updated_at             :datetime
#  registration_quota_id  :integer
#

class RegistrationPrice < ActiveRecord::Base
  belongs_to :registration_type
  belongs_to :registration_period
  belongs_to :registration_quota

  scope :for, ->(period) { where('registration_period_id = ?', period.id) }
end
