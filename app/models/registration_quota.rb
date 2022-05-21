# frozen_string_literal: true

# == Schema Information
#
# Table name: registration_quotas
#
#  closed                :boolean          default(FALSE)
#  created_at            :timestamptz
#  event_id              :bigint(8)
#  id                    :bigint(8)        not null, primary key
#  order                 :bigint(8)
#  price                 :decimal(10, )    not null
#  quota                 :bigint(8)
#  registration_price_id :bigint(8)
#  updated_at            :timestamptz
#

class RegistrationQuota < ApplicationRecord
  belongs_to :event

  has_many :attendances, dependent: :restrict_with_exception

  validates :order, :quota, :price, presence: true

  def vacancy?
    places_sold = reserved + attendances.active.size
    open? && places_sold < quota
  end

  def capacity_left
    quota - (attendances.active.size + reserved)
  end

  private

  def open?
    !closed
  end

  def reserved
    RegistrationGroupRepository.instance.reserved_for_quota(self)
  end
end
