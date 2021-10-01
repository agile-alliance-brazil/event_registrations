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
#  created_at              :datetime         not null
#  due_date                :datetime
#  education_level         :integer          default(0), indexed
#  email_sent              :boolean          default(FALSE)
#  event_id                :bigint(8)        not null, indexed
#  event_price             :decimal(10, )
#  experience_in_agility   :integer          default("no_agile_expirience_informed")
#  id                      :bigint(8)        not null, primary key
#  job_role                :bigint(8)        default("not_informed")
#  last_status_change_date :datetime
#  notes                   :string(255)
#  organization            :string(255)
#  organization_size       :integer          default("no_org_size_informed")
#  other_job_role          :string
#  payment_type            :bigint(8)
#  queue_time              :bigint(8)
#  registered_by_id        :bigint(8)        not null, indexed
#  registration_date       :datetime
#  registration_group_id   :bigint(8)
#  registration_period_id  :bigint(8)        indexed
#  registration_quota_id   :bigint(8)        indexed
#  registration_value      :decimal(10, )
#  source_of_interest      :integer          default("no_source_informed"), not null, indexed
#  state                   :string(255)
#  status                  :bigint(8)
#  updated_at              :datetime         not null
#  user_id                 :bigint(8)        not null, indexed
#  years_of_experience     :integer          default("no_experience_informed"), indexed
#
# Indexes
#
#  idx_4539782_fk_rails_4eb9f97929                         (registered_by_id)
#  idx_4539782_fk_rails_a2b9ca8d82                         (registration_period_id)
#  idx_4539782_index_attendances_on_event_id               (event_id)
#  idx_4539782_index_attendances_on_registration_quota_id  (registration_quota_id)
#  idx_4539782_index_attendances_on_user_id                (user_id)
#  index_attendances_on_education_level                    (education_level)
#  index_attendances_on_source_of_interest                 (source_of_interest)
#  index_attendances_on_years_of_experience                (years_of_experience)
#
# Foreign Keys
#
#  fk_rails_23280a60c9  (registration_quota_id => registration_quotas.id) ON DELETE => restrict ON UPDATE => restrict
#  fk_rails_4eb9f97929  (registered_by_id => users.id) ON DELETE => restrict ON UPDATE => restrict
#  fk_rails_777eb7170a  (event_id => events.id) ON DELETE => restrict ON UPDATE => restrict
#  fk_rails_77ad02f5c5  (user_id => users.id) ON DELETE => restrict ON UPDATE => restrict
#  fk_rails_a2b9ca8d82  (registration_period_id => registration_periods.id) ON DELETE => restrict ON UPDATE => restrict
#

class Attendance < ApplicationRecord
  enum source_of_interest: { no_source_informed: 0, facebook: 1, instagram: 2, linkedin: 3, twitter: 4, whatsapp: 5, friend_referral: 6, community_dissemination: 7, company_dissemination: 8, internet_search: 9 }
  enum years_of_experience: { no_experience_informed: 0, less_than_five: 1, six_to_ten: 2, eleven_to_twenty: 3, twenty_one_to_thirty: 4, thirty_or_more: 5 }
  enum experience_in_agility: { no_agile_expirience_informed: 0, less_than_two: 1, three_to_seven: 2, more_than_seven: 3 }
  enum organization_size: { no_org_size_informed: 0, micro_enterprises: 1, small_enterprises: 2, medium_enterprises: 3, large_enterprises: 4 }

  enum job_role: { not_informed: 0, student: 1, analyst: 2, manager: 3, vp: 4, president: 5, designer: 6, coach: 7,
                   other: 8, developer: 9, teacher: 10, independent_worker: 11, team_manager: 12, portfolio_manager: 13,
                   human_resources: 14 }

  enum status: { waiting: 0, pending: 1, accepted: 2, cancelled: 3, paid: 4, confirmed: 5, showed_in: 6 }
  enum payment_type: { gateway: 1, bank_deposit: 2, statement_agreement: 3 }

  scope :committed_to, -> { where(status: %i[paid confirmed showed_in]) }
  scope :active, -> { where('status <> 0 AND status <> 3') }
  scope :not_cancelled, -> { where('status <> 3') }
  scope :last_biweekly_active, -> { active.where('created_at > ?', 15.days.ago) }
  scope :waiting_approval, -> { where('status = 1 AND registration_group_id IS NOT NULL') }
  scope :non_free, -> { where('registration_value > 0') }
  scope :with_time_in_queue, -> { where('queue_time > 0') }
  scope :not_welcomed, -> { where(welcome_email_sent: false) }

  belongs_to :event
  belongs_to :user
  belongs_to :registered_by_user, class_name: 'User', foreign_key: :registered_by_id, inverse_of: :registered_attendances
  belongs_to :registration_period
  belongs_to :registration_group
  belongs_to :registration_quota

  has_many :payment_notifications, dependent: :destroy

  validates :country, :city, :state, :registration_date, :user, :event, presence: true

  delegate :first_name, to: :user, allow_nil: true
  delegate :last_name, to: :user, allow_nil: true
  delegate :full_name, to: :user, allow_nil: true
  delegate :email, to: :user, allow_nil: true

  delegate :token, to: :registration_group, allow_nil: true
  delegate :name, to: :registration_group, prefix: :group, allow_nil: true
  delegate :name, to: :event, prefix: :event, allow_nil: true
  delegate :disability, to: :user

  before_save :set_last_status_change

  delegate :no_disability?, to: :user
  delegate :disability_not_informed?, to: :user
  delegate :user_locale, to: :user

  def discount
    amount = 1
    amount = 1 - (registration_group.discount / 100.00) if registration_group.present? && registration_group.discount.present?
    amount
  end

  def grouped?
    registration_group.present?
  end

  def advise!
    advised_time = Time.zone.now
    update(advised: true, advised_at: advised_time, due_date: [DateService.instance.skip_weekends(advised_time, event.days_to_charge), event.start_date].min)
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

  def confirmable?
    paid? || pending? || accepted?
  end

  def recoverable?
    cancelled?
  end

  def payable?
    pending? || accepted?
  end

  def accepted!
    return update(status: :paid) if registration_value&.zero?

    update(status: :accepted)
  end

  private

  def set_last_status_change
    self.last_status_change_date = Time.zone.now if last_status_change_date.blank?
  end
end
