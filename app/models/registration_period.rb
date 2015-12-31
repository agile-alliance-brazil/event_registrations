# encoding: UTF-8
# == Schema Information
#
# Table name: registration_periods
#
#  id             :integer          not null, primary key
#  event_id       :integer
#  title          :string
#  start_at       :datetime
#  end_at         :datetime
#  created_at     :datetime
#  updated_at     :datetime
#  price_cents    :integer          default(0), not null
#  price_currency :string           default("BRL"), not null
#

class RegistrationPeriod < ActiveRecord::Base
  belongs_to :event

  monetize :price_cents

  scope :for, ->(datetime) { where('? BETWEEN start_at AND end_at', datetime).order('id desc') }
  scope :ending_after, ->(datetime) { where('? < end_at', datetime).order('id desc') }

end
