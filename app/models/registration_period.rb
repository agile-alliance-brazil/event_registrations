# encoding: UTF-8
# == Schema Information
#
# Table name: registration_periods
#
#  id             :integer          not null, primary key
#  event_id       :integer
#  title          :string(255)
#  start_at       :datetime
#  end_at         :datetime
#  created_at     :datetime
#  updated_at     :datetime
#  price_cents    :integer          default(0), not null
#  price_currency :string(255)      default("BRL"), not null
#

class RegistrationPeriod < ActiveRecord::Base
  belongs_to :event

  monetize :price_cents

  scope :for, ->(datetime) { where('CAST(? AS DATE) BETWEEN CAST(start_at AS DATE) AND CAST(end_at AS DATE)', datetime).order('id desc') }
  scope :ending_after, ->(datetime) { where('? < end_at', datetime).order('id desc') }

  validates :event, :title, :start_at, :end_at, presence: true
end
