# frozen_string_literal: true

# == Schema Information
#
# Table name: registration_periods
#
#  created_at :datetime
#  end_at     :datetime
#  event_id   :integer
#  id         :integer          not null, primary key
#  price      :decimal(10, )    not null
#  start_at   :datetime
#  title      :string(255)
#  updated_at :datetime
#

class RegistrationPeriod < ApplicationRecord
  belongs_to :event

  has_many :attendances, dependent: :restrict_with_exception

  scope :for, ->(datetime) { where('CAST(? AS DATE) BETWEEN CAST(start_at AS DATE) AND CAST(end_at AS DATE)', datetime).order('id desc') }
  scope :ending_after, ->(datetime) { where('? < end_at', datetime).order('id desc') }

  validates :event, :title, :start_at, :end_at, :price, presence: true
end
