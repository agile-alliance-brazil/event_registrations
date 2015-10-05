# == Schema Information
#
# Table name: registration_quota
#
#  id                    :integer          not null, primary key
#  quota                 :integer
#  created_at            :datetime
#  updated_at            :datetime
#  event_id              :integer
#  registration_price_id :integer
#  order                 :integer
#  closed                :boolean          default(FALSE)
#

class RegistrationQuota < ActiveRecord::Base
  belongs_to :event
  belongs_to :registration_price

  has_many :attendances

  def vacancy?
    open? && attendances.active.size < quota
  end

  def price
    registration_price.value
  end

  private

  def open?
    !closed
  end
end
