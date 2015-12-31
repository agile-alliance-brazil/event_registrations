# == Schema Information
#
# Table name: registration_quotas
#
#  id                    :integer          not null, primary key
#  quota                 :integer
#  created_at            :datetime
#  updated_at            :datetime
#  event_id              :integer
#  registration_price_id :integer
#  order                 :integer
#  closed                :boolean          default(FALSE)
#  price_cents           :integer          default(0), not null
#  price_currency        :string           default("BRL"), not null
#

class RegistrationQuota < ActiveRecord::Base
  belongs_to :event

  monetize :price_cents

  has_many :attendances

  def vacancy?
    open? && attendances.active.size < quota
  end

  private

  def open?
    !closed
  end
end
