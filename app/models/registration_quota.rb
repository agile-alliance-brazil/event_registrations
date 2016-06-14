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

class RegistrationQuota < ActiveRecord::Base
  belongs_to :event

  monetize :price_cents

  has_many :attendances

  validates :order, :quota, presence: true

  def vacancy?
    open? && attendances.active.size < quota
  end

  private

  def open?
    !closed
  end
end
