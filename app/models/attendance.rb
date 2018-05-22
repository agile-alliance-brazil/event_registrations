# frozen_string_literal: true

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
#  due_date                :datetime
#  education_level         :string(255)
#  email                   :string(255)
#  email_sent              :boolean          default(FALSE)
#  event_id                :integer          not null, indexed
#  event_price             :decimal(10, )
#  experience_in_agility   :string(255)
#  first_name              :string(255)
#  gender                  :string(255)
#  id                      :integer          not null, primary key
#  job_role                :integer          default("not_informed")
#  last_name               :string(255)
#  last_status_change_date :datetime
#  notes                   :string(255)
#  organization            :string(255)
#  organization_size       :string(255)
#  payment_type            :integer
#  phone                   :string(255)
#  queue_time              :integer
#  registration_date       :datetime
#  registration_group_id   :integer
#  registration_period_id  :integer          indexed
#  registration_quota_id   :integer          indexed
#  registration_value      :decimal(10, )
#  school                  :string(255)
#  state                   :string(255)
#  status                  :integer
#  updated_at              :datetime
#  user_id                 :integer          not null, indexed
#  years_of_experience     :string(255)
#
# Indexes
#
#  fk_rails_a2b9ca8d82                         (registration_period_id)
#  index_attendances_on_event_id               (event_id)
#  index_attendances_on_registration_quota_id  (registration_quota_id)
#  index_attendances_on_user_id                (user_id)
#
# Foreign Keys
#
#  fk_rails_23280a60c9  (registration_quota_id => registration_quotas.id)
#  fk_rails_777eb7170a  (event_id => events.id)
#  fk_rails_77ad02f5c5  (user_id => users.id)
#  fk_rails_a2b9ca8d82  (registration_period_id => registration_periods.id)
#

class Attendance < ApplicationRecord
  before_create :set_last_status_change

  enum job_role: %i[not_informed student analyst manager vp president clevel coach other developer]
  enum status: { waiting: 0, pending: 1, accepted: 2, cancelled: 3, paid: 4, confirmed: 5, showed_in: 6 }
  enum payment_type: { gateway: 1, bank_deposit: 2, statement_agreement: 3 }

  scope :committed_to, -> { where(status: %i[paid confirmed showed_in]) }
  scope :active, -> { where('status <> 0 AND status <> 3') }
  scope :not_cancelled, -> { where('status <> 3') }
  scope :last_biweekly_active, -> { active.where('created_at > ?', 15.days.ago) }
  scope :waiting_approval, -> { where('status = 1 AND registration_group_id IS NOT NULL') }
  scope :non_free, -> { where('registration_value > 0') }
  scope :with_time_in_queue, -> { where('queue_time > 0') }

  belongs_to :event
  belongs_to :user
  belongs_to :registration_period
  belongs_to :registration_group
  belongs_to :registration_quota

  has_many :payment_notifications, dependent: :destroy

  validates :first_name, :last_name, :email, :phone, :country, :city, :state, :registration_date, :user, :event, presence: true
  validates :cpf, presence: true, if: ->(a) { a.in_brazil? }

  validates :first_name, :last_name, presence: true, length: { maximum: 100 }
  validates :phone, :city, :organization, length: { maximum: 100, allow_blank: true }

  validates :email, format: { with: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i }, length: { minimum: 6, maximum: 100 }
  validates :phone, format: { with: /\A[0-9\(\) .\-\+]+\Z/i, allow_blank: true }

  validate :registration_group_valid?
  validate :duplicated_active_email_in_event?, on: :create

  delegate :token, to: :registration_group, allow_nil: true
  delegate :name, to: :registration_group, prefix: :group, allow_nil: true
  delegate :name, to: :event, prefix: :event, allow_nil: true

  usar_como_cpf :cpf

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
    advised_time = Time.zone.now
    update(advised: true, advised_at: advised_time, due_date: [DateService.instance.skip_weekends(advised_time, event.days_to_charge), event.start_date].min)
  end

  def to_pay_the_difference?
    (paid? || confirmed?) && grouped? && registration_group.incomplete?
  end

  def price_band?
    registration_period || registration_quota
  end

  def band_value
    registration_period.try(:price) || registration_quota.try(:price)
  end

  def cancellable?
    waiting? || pending? || accepted? || paid? || confirmed?
  end

  def transferrable?
    paid? || confirmed?
  end

  def confirmable?
    paid? || pending? || accepted?
  end

  def recoverable?
    cancelled?
  end

  def payable?
    pending? || accepted?
  end

  private

  def set_last_status_change
    self.last_status_change_date = Time.zone.now if last_status_change_date.blank?
  end

  def registration_group_valid?
    if registration_group&.vacancies?
      self.status = :accepted if registration_group.automatic_approval?
    elsif registration_group.present? && !registration_group.vacancies?
      errors.add(:registration_group, I18n.t('attendances.create.errors.group_full'))
    end
  end

  def duplicated_active_email_in_event?
    duplicated_attendance = event&.attendances&.not_cancelled&.find_by(email: email)
    return if duplicated_attendance.blank?
    errors.add(:email, I18n.t('flash.attendance.create.already_existent'))
  end
end
