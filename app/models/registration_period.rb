# encoding: UTF-8

# == Schema Information
#
# Table name: registration_periods
#
#  created_at     :datetime
#  end_at         :datetime
#  event_id       :integer
#  id             :integer          not null, primary key
#  price_cents    :integer          default(0), not null
#  price_currency :string           default("BRL"), not null
#  start_at       :datetime
#  title          :string
#  updated_at     :datetime
#

class RegistrationPeriod < ApplicationRecord
  belongs_to :event

  monetize :price_cents

  scope :for, ->(datetime) { where('CAST(? AS DATE) BETWEEN CAST(start_at AS DATE) AND CAST(end_at AS DATE)', datetime).order('id desc') }
  scope :ending_after, ->(datetime) { where('? < end_at', datetime).order('id desc') }

  validates :event, :title, :start_at, :end_at, presence: true
end
