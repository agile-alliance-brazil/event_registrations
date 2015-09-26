# encoding: UTF-8
# == Schema Information
#
# Table name: attendances
#
#  id                     :integer          not null, primary key
#  event_id               :integer
#  user_id                :integer
#  registration_type_id   :integer
#  registration_group_id  :integer
#  registration_date      :datetime
#  status                 :string
#  email_sent             :boolean          default(FALSE)
#  created_at             :datetime
#  updated_at             :datetime
#  first_name             :string
#  last_name              :string
#  email                  :string
#  organization           :string
#  phone                  :string
#  country                :string
#  state                  :string
#  city                   :string
#  badge_name             :string
#  cpf                    :string
#  gender                 :string
#  twitter_user           :string
#  address                :string
#  neighbourhood          :string
#  zipcode                :string
#  notes                  :string
#  event_price            :decimal(, )
#  registration_quota_id  :integer
#  registration_value     :decimal(, )
#  registration_period_id :integer
#  advised                :boolean          default(FALSE)
#  advised_at             :datetime
#

class Attendance < ActiveRecord::Base
  include Concerns::LifeCycle

  SUPER_EARLY_LIMIT = 150

  belongs_to :event
  belongs_to :user
  belongs_to :registration_type
  belongs_to :registration_period
  belongs_to :registration_group
  belongs_to :registration_quota
  has_many :payment_notifications, as: :invoicer

  has_many :invoice_attendances
  has_many :invoices, -> { uniq }, through: :invoice_attendances

  validates_confirmation_of :email
  validates_presence_of [:first_name, :last_name, :email, :phone, :country, :city, :registration_date, :user_id, :event_id]
  validates_presence_of :state, if: ->(a) { a.in_brazil? }
  validates_presence_of :cpf, if: ->(a) { a.in_brazil? }

  validates_length_of [:first_name, :last_name, :phone, :city, :organization], maximum: 100, allow_blank: true
  validates_format_of :email, with: /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i, allow_blank: true
  validates_length_of :email, within: 6..100, allow_blank: true

  validates_format_of :phone, with: /\A[0-9\(\) .\-\+]+\Z/i, allow_blank: true

  after_save :update_group_invoice

  delegate :token, to: :registration_group
  delegate :name, to: :registration_group, prefix: :group, allow_nil: true

  usar_como_cpf :cpf

  scope :for_event, ->(e) { where(event_id: e.id) }
  scope :for_registration_type, ->(t) { where(registration_type_id: t.id) }
  scope :without_registration_type, ->(t) { where("#{table_name}.registration_type_id != (?)", t.id) }
  scope :active, -> { where('status != (?)', :cancelled) }
  scope :older_than, ->(date) { where('registration_date < (?)', date) }
  scope :search_for_list, lambda { |param|
    where('first_name LIKE ? OR last_name LIKE ? OR organization LIKE ? OR email LIKE ? OR id = ?',
    "%#{param}%", "%#{param}%", "%#{param}%", "%#{param}%", "#{param}").order(created_at: :desc)
  }
  scope :attendances_for, ->(user_param) { where('user_id = ?', user_param.id).order(created_at: :asc) }
  scope :for_cancelation_warning, lambda {
    older_than(7.days.ago).where("attendances.status IN ('pending', 'accepted') AND advised = ?", false)
      .joins(:invoices).where('invoices.payment_type = ?', Invoice::GATEWAY)
  }

  scope :for_cancelation, -> { where("attendances.status IN ('pending', 'accepted') AND advised = ? AND advised_at < (?)", true, 7.days.ago) }
  scope :last_biweekly_active, -> { active.where('created_at > ?', 15.days.ago) }
  scope :waiting_approval, -> { where("status = 'pending' AND registration_group_id IS NOT NULL") }

  def full_name
    [first_name, last_name].join(' ')
  end

  def in_brazil?
    self.country == 'BR'
  end

  def discount
    amount = 1
    amount = 1 - (registration_group.discount / 100.00) if registration_group.present?
    amount
  end

  def payment_type
    invoices.individual.last.payment_type if invoices.present?
  end

  def grouped?
    registration_group.present?
  end

  def advise!
    update_attributes(advised: true, advised_at: Time.zone.now)
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << [:first_name, :last_name, :organization, :email]
      all.find_each do |attendance|
        csv << [attendance.first_name, attendance.last_name, attendance.organization, attendance.email]
      end
    end
  end

  private

  def update_group_invoice
    registration_group.update_invoice if registration_group.present? && registration_value.present?
  end
end
