# encoding: UTF-8
# == Schema Information
#
# Table name: attendances
#
#  advised                 :boolean          default(FALSE)
#  advised_at              :datetime
#  badge_name              :string(255)
#  city                    :string(255)
#  country                 :string(255)
#  cpf                     :string(255)
#  created_at              :datetime
#  education_level         :string(255)
#  email                   :string(255)
#  email_sent              :boolean          default(FALSE)
#  event_id                :integer
#  event_price             :decimal(10, )
#  experience_in_agility   :string(255)
#  first_name              :string(255)
#  gender                  :string(255)
#  id                      :integer          not null, primary key
#  job_role                :string(255)
#  last_name               :string(255)
#  last_status_change_date :datetime
#  notes                   :string(255)
#  organization            :string(255)
#  organization_size       :string(255)
#  payment_type            :string(255)
#  phone                   :string(255)
#  queue_time              :integer
#  registration_date       :datetime
#  registration_group_id   :integer
#  registration_period_id  :integer
#  registration_quota_id   :integer
#  registration_value      :decimal(10, )
#  school                  :string(255)
#  state                   :string(255)
#  status                  :string(255)
#  updated_at              :datetime
#  user_id                 :integer
#  years_of_experience     :string(255)
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
    return event.start_date if !advised_due_date.present? || advised_due_date > event.start_date
    advised_due_date
  end

  def free?
    registration_group.try(:free?)
  end

  private

  def advised_due_date
    advised_at + event.days_to_charge.days if advised_at.present?
  end

  def update_group_invoice
    registration_group.update_invoice if registration_group.present? && registration_value.present?
  end

  def set_last_status_change
    self.last_status_change_date = Time.zone.now unless last_status_change_date.present?
  end
end
