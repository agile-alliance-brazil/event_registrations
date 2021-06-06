# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  address                :string(255)
#  badge_name             :string(255)
#  city                   :string(255)
#  confirmation_sent_at   :datetime
#  confirmation_token     :string(255)      indexed
#  confirmed_at           :datetime
#  country                :string(255)
#  cpf                    :string(255)
#  created_at             :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string(255)
#  default_locale         :string(255)      default("pt")
#  email                  :string(255)      not null, indexed
#  encrypted_password     :string(255)      default(""), not null
#  failed_attempts        :integer          default(0), not null
#  first_name             :string(255)      not null
#  gender                 :string(255)
#  id                     :integer          not null, primary key
#  last_name              :string(255)      not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string(255)
#  locked_at              :datetime
#  neighbourhood          :string(255)
#  organization           :string(255)
#  phone                  :string(255)
#  registration_group_id  :integer          indexed
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string(255)      indexed
#  role                   :integer          default("user"), not null
#  roles_mask             :integer
#  sign_in_count          :integer          default(0), not null
#  state                  :string(255)
#  twitter_user           :string(255)
#  unconfirmed_email      :string(255)
#  unlock_token           :string(255)      indexed
#  updated_at             :datetime
#  user_image             :string(255)
#  zipcode                :string(255)
#
# Indexes
#
#  fk_rails_ebe9fba698                  (registration_group_id)
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_ebe9fba698  (registration_group_id => registration_groups.id)
#

class User < ApplicationRecord
  enum role: { user: 0, organizer: 1, admin: 2 }

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable, :omniauthable

  devise :omniauthable, omniauth_providers: %i[github facebook twitter]

  mount_uploader :user_image, RegistrationsImageUploader

  has_many :attendances, dependent: :destroy
  has_many :events, -> { distinct }, through: :attendances, dependent: :nullify
  has_many :payment_notifications, through: :attendances, dependent: :destroy
  has_many :led_groups, class_name: 'RegistrationGroup', inverse_of: :leader, foreign_key: :leader_id, dependent: :nullify
  has_many :registered_attendances, class_name: 'Attendance', inverse_of: :registered_by_user, foreign_key: :registered_by_id, dependent: :restrict_with_exception

  has_and_belongs_to_many :organized_events, class_name: 'Event'

  validates :default_locale, inclusion: %w[en pt]
  validates :first_name, :last_name, presence: true, length: { maximum: 100 }
  validates :email, format: { with: /\A([\w.%+\-]+)@([\w\-]+\.)+(\w{2,})\z/i, allow_blank: true }
  validates :email, uniqueness: { case_sensitive: false, allow_blank: true }

  usar_como_cpf :cpf

  def self.from_omniauth(omniauth_params)
    name = omniauth_params.info.name
    where(email: omniauth_params.info.email).first_or_create do |user|
      name_parts = name.split
      user.first_name = name_parts.shift
      user.last_name = if name_parts.empty?
                         user.first_name
                       else
                         name_parts.join(' ')
                       end

      user.password = Devise.friendly_token[0, 20]
    end
  end

  def registrations_for_event(event)
    attendances.select { |attendance| attendance.event_id == event.id }
  end

  def gender=(value)
    self[:gender] = value.nil? ? nil : value == 'M'
  end

  def twitter_user=(value)
    self[:twitter_user] = value.try(:start_with?, '@') ? value[1..] : value
  end

  def full_name
    [first_name.titleize, last_name.titleize].join(' ')
  end

  def organizer_of?(event)
    return false if user?
    return true if admin?

    organized_events.include?(event)
  end

  def toggle_admin
    if admin?
      update(role: :user)
    else
      update(role: :admin)
    end
  end

  def toggle_organizer
    if organizer?
      update(role: :user)
    else
      update(role: :organizer)
    end
  end
end
