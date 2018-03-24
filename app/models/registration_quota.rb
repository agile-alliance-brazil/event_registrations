# frozen_string_literal: true

# == Schema Information
#
# Table name: registration_quotas
#
#  closed                :boolean          default(FALSE)
#  created_at            :datetime
#  event_id              :integer
#  id                    :integer          not null, primary key
#  order                 :integer
#  price_cents           :integer          default(0), not null
#  price_currency        :string           default("BRL"), not null
#  quota                 :integer
#  registration_price_id :integer
#  updated_at            :datetime
#

class RegistrationQuota < ApplicationRecord
  belongs_to :event

  monetize :price_cents

  has_many :attendances, dependent: :restrict_with_exception

  validates :order, :quota, presence: true

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
