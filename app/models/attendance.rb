# encoding: UTF-8

# == Schema Information
#
# Table name: attendances
#
#  advised                 :boolean          default(FALSE)
#  advised_at              :datetime
#  badge_name              :string
#  city                    :string
#  country                 :string
#  cpf                     :string
#  created_at              :datetime
#  education_level         :string
#  email                   :string
#  email_sent              :boolean          default(FALSE)
#  event_id                :integer
#  event_price             :decimal(10, )
#  experience_in_agility   :string
#  first_name              :string
#  gender                  :string
#  id                      :integer          not null, primary key
#  job_role                :string
#  last_name               :string
#  last_status_change_date :datetime
#  notes                   :string
#  organization            :string
#  organization_size       :string
#  payment_type            :string
#  phone                   :string
#  queue_time              :integer
#  registration_date       :datetime
#  registration_group_id   :integer
#  registration_period_id  :integer
#  registration_quota_id   :integer
#  registration_value      :decimal(10, )
#  school                  :string
#  state                   :string
#  status                  :string
#  updated_at              :datetime
#  user_id                 :integer
#  years_of_experience     :string
#
# Indexes
#
#  index_attendances_on_registration_quota_id  (registration_quota_id)
#

class Attendance < ActiveRecord::Base
  include Concerns::LifeCycle
  before_create :set_last_status_change

  belongs_to :event
  belongs_to :user
  belongs_to :registration_period
  belongs_to :registration_group
  belongs_to :registration_quota
  has_many :payment_notifications, as: :invoicer

  has_many :invoices, as: :invoiceable

  validates :first_name, :last_name, :email, :phone, :country, :city, :state, :registration_date, :user, :event, presence: true
  validates :cpf, presence: true, if: ->(a) { a.in_brazil? }

  validates :first_name, :last_name, presence: true, length: { maximum: 100 }
  validates :phone, :city, :organization, length: { maximum: 100, allow_blank: true }

  validates :email, format: { with: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i }, length: { minimum: 6, maximum: 100 }
  validates :phone, format: { with: /\A[0-9\(\) .\-\+]+\Z/i, allow_blank: true }

  after_save :update_group_invoice

  delegate :token, to: :registration_group, allow_nil: true
  delegate :name, to: :registration_group, prefix: :group, allow_nil: true
  delegate :name, to: :event, prefix: :event, allow_nil: true

  usar_como_cpf :cpf

  scope :last_biweekly_active, -> { active.where('created_at > ?', 15.days.ago) }
  scope :waiting_approval, -> { where("status = 'pending' AND registration_group_id IS NOT NULL") }
  scope :already_paid, -> { where("attendances.status IN ('paid', 'confirmed')") }
  scope :non_free, -> { where('registration_value > 0') }
  scope :with_time_in_queue, -> { where('queue_time > 0') }

  def full_name
    [first_name, last_name].join(' ')
  end

  def in_brazil?
    country == 'BR'
  end

  def discount
    amount = 1
    amount = 1 - (registration_group.discount / 100.00) if registration_group.present?
    amount
  end

  def grouped?
    registration_group.present?
  end

  def to_s
    "#{last_name}, #{first_name}"
  end

  def advise!
    update_attributes(advised: true, advised_at: Time.zone.now)
  end

  def due_date
    return event.start_date if advised_due_date.blank? || advised_due_date > event.start_date
    advised_due_date
  end

  def free?
    registration_group.try(:free?)
  end

  def to_pay_the_difference?
    (paid? || confirmed?) && grouped? && registration_group.incomplete?
  end

  def payment_type
    invoices.last.try(:payment_type)
  end

  def price_band?
    registration_period || registration_quota
  end

  def band_value
    registration_period.try(:price) || registration_quota.try(:price)
  end

  private

  def advised_due_date
    advised_at + event.days_to_charge.days if advised_at.present?
  end

  def update_group_invoice
    registration_group.update_invoice if registration_group.present? && registration_value.present?
  end

  def set_last_status_change
    self.last_status_change_date = Time.zone.now if last_status_change_date.blank?
  end
end
