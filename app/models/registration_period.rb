# frozen_string_literal: true

# == Schema Information
#
# Table name: registration_periods
#
#  created_at :datetime         not null
#  end_at     :datetime
#  event_id   :bigint(8)
#  id         :bigint(8)        not null, primary key
#  price      :decimal(10, )    not null
#  start_at   :datetime
#  title      :string(255)
#  updated_at :datetime         not null
#

class RegistrationPeriod < ApplicationRecord
  belongs_to :event

  has_many :attendances, dependent: :restrict_with_exception

  scope :for, ->(analysed_date) { where(':analysed_date BETWEEN start_at AND end_at', analysed_date: analysed_date).order('id desc') }
  scope :ending_after, ->(datetime) { where('? < end_at', datetime).order('id desc') }

  validates :title, :start_at, :end_at, :price, presence: true
end
